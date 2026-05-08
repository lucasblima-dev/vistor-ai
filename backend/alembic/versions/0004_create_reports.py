"""create reports table

Revision ID: 0004
Revises: 0003
Create Date: 2026-05-08 16:15:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = '0004'
down_revision: Union[str, None] = '0003'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'reports',
        sa.Column('id', sa.UUID(), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('inspection_id', sa.UUID(), nullable=False),
        sa.Column('generated_by', sa.UUID(), nullable=False),
        sa.Column('minio_key', sa.Text(), nullable=False),
        sa.Column('sha256', sa.String(length=64), nullable=False),
        sa.Column('signature_key', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.ForeignKeyConstraint(['generated_by'], ['users.id'], ),
        sa.ForeignKeyConstraint(['inspection_id'], ['inspections.id'], ),
        sa.PrimaryKeyConstraint('id')
    )


def downgrade() -> None:
    op.drop_table('reports')
