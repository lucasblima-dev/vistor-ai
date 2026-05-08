"""create inspections table

Revision ID: 0002
Revises: 0001
Create Date: 2026-05-08 16:05:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
from geoalchemy2 import Geometry

# revision identifiers, used by Alembic.
revision: str = '0002'
down_revision: Union[str, None] = '0001'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Enable PostGIS
    op.execute("CREATE EXTENSION IF NOT EXISTS postgis")

    # Create Enums
    sa.Enum('critical', 'moderate', 'low', 'pending_review', name='severity_enum').create(op.get_bind())
    sa.Enum('draft', 'open', 'in_progress', 'resolved', 'archived', name='status_enum').create(op.get_bind())

    op.create_table(
        'inspections',
        sa.Column('id', sa.UUID(), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('inspector_id', sa.UUID(), nullable=False),
        sa.Column('assigned_to', sa.UUID(), nullable=True),
        sa.Column('category', sa.String(length=60), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('severity', postgresql.ENUM('critical', 'moderate', 'low', 'pending_review', name='severity_enum', create_type=False), nullable=True),
        sa.Column('ai_label', sa.String(), nullable=True),
        sa.Column('ai_score', sa.Float(), nullable=True),
        sa.Column('ai_raw', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('human_label', sa.String(), nullable=True),
        sa.Column('location', Geometry(geometry_type='POINT', srid=4326, from_text='ST_GeomFromEWKT', name='geometry', spatial_index=False), nullable=False),
        sa.Column('gps_accuracy', sa.Float(), nullable=False),
        sa.Column('address', sa.Text(), nullable=True),
        sa.Column('status', postgresql.ENUM('draft', 'open', 'in_progress', 'resolved', 'archived', name='status_enum', create_type=False), server_default='open', nullable=False),
        sa.Column('deleted_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.ForeignKeyConstraint(['assigned_to'], ['users.id'], ),
        sa.ForeignKeyConstraint(['inspector_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    
    # Indices
    op.execute("CREATE INDEX idx_inspections_location ON inspections USING GIST (location)")
    op.execute("""
        CREATE INDEX idx_inspections_active 
        ON inspections (created_at DESC) 
        WHERE deleted_at IS NULL
    """)


def downgrade() -> None:
    op.drop_table('inspections')
    sa.Enum(name='severity_enum').drop(op.get_bind())
    sa.Enum(name='status_enum').drop(op.get_bind())
    # Note: We don't drop postgis extension to avoid breaking other things
