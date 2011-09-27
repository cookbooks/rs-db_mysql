# Cookbook Name:: db
#
# Copyright (c) 2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

rs_utils_marker :begin

DATA_DIR = node[:db][:data_dir]

# Make sure the node variables related to master are set on this instance
include_recipe 'db_mysql::do_lookup_master'
log "  Performing pre-backup check..." unless node[:db][:backup][:force] == true
db DATA_DIR do
  # Skip checks if force is used.
  not_if node[:db][:backup][:force]
  action [ :pre_backup_check ]
end

log "  Performing lock DB and write backup info file..."
db DATA_DIR do
  action [ :lock, :write_backup_info ]
end

log "  Performing Snapshot..."
# Requires block_device node[:db][:block_device] to be instantiated
# previously. Make sure block_device::default recipe has been run.
# TODO: add as master so that a new slave after promotion can kick off a backup
# without waiting for DNS and tags to propagate.  MVP??
block_device DATA_DIR do
  lineage node[:db][:backup][:lineage]
  action :snapshot
end

log "  Performing unlock DB..."
db DATA_DIR do
  action :unlock
end

log "  Performing Backup and post-backup cleanup..."
# Requires block_device node[:db][:block_device] to be instantiated
# previously. Make sure block_device::default recipe has been run.
execute "backup.rb" do
  command "/opt/rightscale/sandbox/bin/backup.rb --backuponly --lineage=#{node[:db][:backup][:lineage]} &"
  action :run
end

rs_utils_marker :end