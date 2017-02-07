# -*- coding: utf-8 -*-
#
# This file is part of CERN Document Server.
# Copyright (C) 2017 CERN.
#
# CERN Document Server is free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# CERN Document Server is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with CERN Document Server; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307, USA.
#
# In applying this license, CERN does not
# waive the privileges and immunities granted to it by virtue of its status
# as an Intergovernmental Organization or submit itself to any jurisdiction.

"""CDS redirector views."""

from __future__ import absolute_import, print_function

from flask import Blueprint, redirect, url_for
from invenio_pidstore.models import PersistentIdentifier

blueprint = Blueprint(
    'cds_redirector',
    __name__,
    template_folder='templates',
    static_folder='static',
)


# /record/<pid_value>/embed/<filename>
# /video/<report_number>/
@blueprint.route('/video/<report_number>')
def video_embed_alias(report_number):
    """Redirect from the old video embed URL to the new one."""
    object_uuid = PersistentIdentifier.query.filter_by(
        pid_type='rn',
        pid_value=report_number
    ).one().object_uuid
    recid = PersistentIdentifier.query.filter_by(
        pid_type='recid',
        object_type='rec',
        object_uuid=object_uuid
    ).one().pid_value
    return redirect(url_for(
        'invenio_records_ui.recid_embed',
        pid_value=recid,
        filename=''), code=301)
