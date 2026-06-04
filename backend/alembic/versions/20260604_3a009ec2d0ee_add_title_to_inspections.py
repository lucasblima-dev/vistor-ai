"""add_title_to_inspections

Revision ID: 3a009ec2d0ee
Revises: 0006
Create Date: 2026-06-04 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '3a009ec2d0ee'
down_revision = '0006'
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('inspections', sa.Column('title', sa.String(100), nullable=True))
    # Preenche com valor padrão para registros existentes
    op.execute("UPDATE inspections SET title = category")
    op.alter_column('inspections', 'title', nullable=False)


def downgrade():
    op.drop_column('inspections', 'title')
