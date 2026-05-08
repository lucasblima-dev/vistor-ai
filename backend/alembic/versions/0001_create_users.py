"""create users table

Revision ID: 0001
Revises: 
Create Date: 2026-05-08 16:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '0001'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create Enum
    sa.Enum('inspector', 'manager', 'admin', name='role_enum').create(op.get_bind())

    op.create_table(
        'users',
        sa.Column('id', sa.UUID(), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('name', sa.String(), nullable=False),
        sa.Column('email', sa.String(), nullable=False),
        sa.Column('password', sa.String(), nullable=False),
        sa.Column('role', postgresql.ENUM('inspector', 'manager', 'admin', name='role_enum', create_type=False), nullable=False),
        sa.Column('is_active', sa.Boolean(), server_default=sa.text('true'), nullable=False),
        sa.Column('failed_attempts', sa.Integer(), server_default=sa.text('0'), nullable=False),
        sa.Column('locked_until', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('idx_users_email'), 'users', ['email'], unique=True)


def downgrade() -> None:
    op.drop_index(op.f('idx_users_email'), table_name='users')
    op.drop_table('users')
    sa.Enum(name='role_enum').drop(op.get_bind())
