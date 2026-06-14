from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from uuid import UUID

from app.dependencies.db import get_db
from app.dependencies.auth import get_current_user
from app.services import pdf_service, storage_service
from app.models.report import Report
from app.schemas.report import ReportCreate, ReportOut

router = APIRouter()

async def generate_report_wrapper(inspection_id: UUID, generated_by: UUID):
    """Wrapper para garantir que a tarefa de background tenha sua própria sessão de banco."""
    from app.database import AsyncSessionLocal
    async with AsyncSessionLocal() as db:
        await pdf_service.generate_report(inspection_id, db, generated_by)

@router.post("/generate", status_code=status.HTTP_202_ACCEPTED)
async def generate_report_task(
    payload: ReportCreate,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    user = Depends(get_current_user)
):
    """Dispara a geração de um laudo PDF em segundo plano."""
    # Verifica se já existe um laudo
    query = select(Report).where(Report.inspection_id == payload.inspection_id)
    report = await db.scalar(query)
    
    if report:
        return {"report_id": report.id, "status": "exists", "message": "Relatório já gerado anteriormente."}

    # Adiciona a tarefa em background usando o wrapper
    background_tasks.add_task(
        generate_report_wrapper,
        payload.inspection_id,
        user.id
    )
    
    return {"status": "generating", "message": "O laudo está sendo processado."}

@router.get("/", response_model=list[ReportOut])
async def list_reports(
    db: AsyncSession = Depends(get_db),
    user = Depends(get_current_user)
):
    """Lista todos os laudos, filtrando por permissão (inspetores veem os seus, gestores todos)."""
    from app.models.user import User
    from app.models.inspection import Inspection
    query = select(Report, User.name, Inspection.title).join(User, Report.generated_by == User.id).join(Inspection, Report.inspection_id == Inspection.id).order_by(Report.created_at.desc())
    
    if user.role == "inspector":
        query = query.where(Report.generated_by == user.id)
        
    result = await db.execute(query)
    rows = result.all()
    
    out_reports = []
    for report, user_name, inspection_title in rows:
        r_out = ReportOut.model_validate(report)
        r_out.generator_name = user_name
        r_out.inspection_title = inspection_title
        out_reports.append(r_out)
        
    return out_reports

@router.get("/{id}", response_model=ReportOut)
async def get_report(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    user = Depends(get_current_user)
):
    """Retorna os dados do laudo e a URL de download, após verificar a integridade."""
    from app.models.user import User
    from app.models.inspection import Inspection
    query = select(Report, User.name, Inspection.title).join(User, Report.generated_by == User.id).join(Inspection, Report.inspection_id == Inspection.id).where(Report.id == id)
    row = (await db.execute(query)).first()
    
    if not row:
        raise HTTPException(status_code=404, detail="Relatório não encontrado")

    report, user_name, inspection_title = row

    # Verifica o hash antes de retornar
    is_valid = await pdf_service.verify_report_hash(id, db)
    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT, 
            detail="Divergência de integridade detectada no laudo. Notifique o administrador."
        )

    # Gera URL de download
    download_url = await storage_service.get_presigned_download_url(
        bucket="reports",
        key=report.minio_key,
        expires=3600
    )
    
    report_out = ReportOut.model_validate(report)
    report_out.generator_name = user_name
    report_out.inspection_title = inspection_title
    report_out.download_url = download_url
    
    return report_out
