# Copyright (C) Canonical, Ltd.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

add_library(formatter STATIC
  csv_formatter.cpp
  format_utils.cpp
  json_formatter.cpp
  table_formatter.cpp
  yaml_formatter.cpp)

target_link_libraries(formatter
  client_common
  fmt::fmt-header-only
  rpc
  settings
  utils
  yaml
  Qt6::Core)
