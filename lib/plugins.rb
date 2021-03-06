require 'date'
require 'feedzirra'
require 'hpricot'
require 'mechanize'
require 'net/http'
require 'sqlite3'
require 'uri'

require_relative 'plugins/find_jira_ticket'
require_relative 'plugins/jira_ticket_create_notify'
require_relative 'plugins/jira_ticket_create_notify_crons'
require_relative 'plugins/send_help'
require_relative 'plugins/thats_what_she_said'
