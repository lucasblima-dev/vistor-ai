"""add fcm token to users

Revision ID: 20260609_add_fcm_token_to_users
Revises: 20260604_3a009ec2d0ee_add_title_to_inspections
Create Date: 2026-06-09 10:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '20260609_add_fcm_token_to_users'
down_revision = '3a009ec2d0ee'
branch_labels = None
depends_on = None

def upgrade():
    op.add_column('users', sa.Column('fcm_token', sa.String(), nullable=True))

def downgrade():
    op.drop_column('users', 'fcm_token')
