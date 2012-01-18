#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin
version="5.5"

log "Setting DB MySQL version to #{version}"
node[:db_mysql][:version] = version

rs_utils_marker :end
