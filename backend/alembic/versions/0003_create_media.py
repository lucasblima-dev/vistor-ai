"""create media table

Revision ID: 0003
Revises: 0002
Create Date: 2026-05-08 16:10:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '0003'
down_revision: Union[str, None] = '0002'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create Enum
    sa.Enum('photo', 'video', 'pdf', name='media_type_enum').create(op.get_bind())

    op.create_table(
        'media',
        sa.Column('id', sa.UUID(), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('inspection_id', sa.UUID(), nullable=False),
        sa.Column('type', postgresql.ENUM('photo', 'video', 'pdf', name='media_type_enum', create_type=False), nullable=False),
        sa.Column('minio_key', sa.Text(), nullable=False),
        sa.Column('thumbnail_key', sa.Text(), nullable=True),
        sa.Column('mime_type', sa.String(length=80), nullable=False),
        sa.Column('size_bytes', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.ForeignKeyConstraint(['inspection_id'], ['inspections.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )


def downgrade() -> None:
    op.drop_table('media')
    sa.Enum(name='media_type_enum').drop(op.get_bind())
