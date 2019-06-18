# Copyright(C) 2019 Sutou Kouhei <kou@clear-code.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License version 2.1 as published by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

module GroongaLog
  def expected_groonga_log(level, messages)
    log_file = Tempfile.new("groonga-log")
    log_file.close
    groonga("status",
            command_line: [
              "--log-path", log_file.path,
              "--log-level", level,
            ])
    standard_log_lines = normalize_groonga_log(File.read(log_file.path)).lines
    log = standard_log_lines[0..-2].join("")
    unless messages.empty?
      messages.each_line do |message|
        log << "1970-01-01 00:00:00.000000#{message}"
      end
    end
    log << standard_log_lines[-1] # grn_fin
    log
  end

  def prepend_tag(tag, messages)
    messages.each_line.inject("") do |result, line|
      result + "#{tag}#{line}"
    end
  end

  def normalize_init_line(line)
    line.chomp.gsub(/\A
                       (\d{4}-\d{2}-\d{2}\ \d{2}:\d{2}:\d{2}\.\d+)?
                       \|\
                       ([a-zA-Z])
                       \|\
                       ([^: ]+)?
                       ([|:]\ )?
                       (.+)
                    \z/x) do
      timestamp = $1
      level = $2
      id_section = $3
      separator = $4
      message = $5
      timestamp = "1970-01-01 00:00:00.000000" if timestamp
      case id_section
      when nil
      when /\|/
        id_section = "PROCESS_ID|THREAD_ID"
      when /[a-zA-Z]/
        id_section = "THREAD_ID"
      when /\A\d{8,}\z/
        id_section = "THREAD_ID"
      else
        id_section = "PROCESS_ID"
      end
      message = message.gsub(/grn_init: <.+?>/, "grn_init: <VERSION>")
      timestamp.to_s +
        "|" +
        level +
        "|" +
        id_section.to_s +
        separator.to_s +
        message
    end
  end

  def normalize_groonga_log(text)
    normalized = ""
    text.split("\n").each do |line|
      line = normalize_init_line(line)
      next if stack_trace?(line)
      # normalize temporary file generated by grn_mkstemp
      replaced = line.gsub(/: <(.+\.db\.\d{7})[0-9a-zA-Z]{6}>/) do |path|
        ": <#{$1}XXXXXX>"
      end
      normalized << "#{replaced}\n"
    end
    normalized
  end

  private
  def stack_trace?(line)
    /\|e\| (.+?)\((.+?)\) \[(0x.+?)\]$/.match?(line)
  end
end
