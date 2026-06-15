"""add_user_avatar_key

Revision ID: 2f8e78c02adc
Revises: 20260609_add_fcm_token_to_users
Create Date: 2026-06-14 20:25:05.431154

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = '2f8e78c02adc'
down_revision: Union[str, None] = '20260609_add_fcm_token_to_users'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('users', sa.Column('avatar_key', sa.String(), nullable=True))


def downgrade() -> None:
    op.drop_column('users', 'avatar_key')
