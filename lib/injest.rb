require "open-uri"
require "nokogiri"

module Injest
  # Tested with the following return versions:
  # 2015v2.1
  # 2016v3.0
  # 2017v2.2
  # 2017v2.3
  # 2018v3.1
  # 2020v4.0
  # 2020v4.1
  # In production, I'd be more explicit about version handling. Different functions would likely
  # need to parse different return versions in slightly different ways, so we'd probably want to
  # parse the version into an actual number do do these checks.
  # For example,
  #
  #   if version < 202040
  #     parse_node_old_way node
  #   else
  #     parse_node_new_way node
  #   end
  #
  def self.injest_files(uris)
    # I'm running this in a transaction so that the entire operation fails if something goes wrong,
    # and we don't end up with part of a file parsed + inserted. In production, I'd probably put a
    # bit more effort into making this Organization idempotent, such that we wouldn't need to keep
    # the transaction open for the whole lifetime.
    ActiveRecord::Base.transaction do
      uris.each do |uri|
        puts "Injesting file #{uri}"
        num_saved_orgs = 0
        num_skipped_orgs = 0
        num_saved_awards = 0
        # I'm just going to let exceptions be thrown here, as they should halt execution and
        # provide the runner with a stack trace, which is basically what we want. If this was more
        # user facing, I might rescue and handle the exceptions more nicely.
        xml_text = URI.open(uri).read
        xml_doc = Nokogiri::XML::parse xml_text

        # Using CSS selectors is simple, but might cause issues because we're ignoring the XML namespace.
        # I'd have to check with someone to see if this could actually be an issue.

        # Assuming there can only be one header. In production, I'd probably check and throw a
        # validation error if there were multiple headers.
        return_header_node = xml_doc.css("Return ReturnHeader")[0]
        filer_node = return_header_node.css("Filer")[0]
        if filer_node.nil?
          raise "Found <ReturnHeader> without a <Filer>."
        end
        filer = Organization.from_xml filer_node
        existing_org = Organization.where(ein: filer.ein, name: filer.name).first
        if existing_org == nil
          filer.save!
          num_saved_orgs += 1
        else
          filer = existing_org
          num_skipped_orgs += 1
        end
        filing = Filing.from_xml return_header_node, filer.id
        filing.save!

        xml_doc.css("Return ReturnData IRS990ScheduleI RecipientTable").each do |recipient_table_node|
          begin
            recipient = Organization.from_xml recipient_table_node
          rescue StandardError => e
            puts "Encountered invalid <RecipientTable>.\nmessage = #{e.message}\nline = #{recipient_table_node.line}\nnode = #{recipient_table_node.to_s}\nThis can happen sometimes with malformed inputs. Skipping this recipient."
            next
          end
          existing_org = Organization.where(ein: recipient.ein, name: recipient.name).first
          if existing_org == nil
            recipient.save!
            num_saved_orgs += 1
          else
            recipient = existing_org
            num_skipped_orgs += 1
          end
          award = Award.from_xml recipient_table_node, filing.id, recipient.id
          award.save!
          num_saved_awards += 1
        end
        puts "Saved 1 filing, #{num_saved_orgs} organizations (#{num_skipped_orgs} skipped), #{num_saved_awards} awards"
      end
    end
  end
end
