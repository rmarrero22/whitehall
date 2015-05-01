desc "Generates and emails CSV reports of all public documents containing broken links."
task :generate_broken_link_reports => :environment do
  begin
    reports_dir     = args[:reports_dir]
    email_address   = args[:email_address]
    report_zip_name = "broken-link-reports-#{Date.today.strftime}.zip"
    report_zip_path = Pathname.new(reports_dir).join(report_zip_name)
    logger          = Logger.new(Rails.root.join('log/broken_link_reporting.log'))

    logger.info("Cleaning up any existing reports.")
    FileUtils.mkpath reports_dir
    FileUtils.rm Dir.glob(reports_dir + '/*_broken_links.csv')
    FileUtils.rm(report_zip_path) if File.exists?(report_zip_path)

    logger.info("Generating broken link reports...")
    Whitehall::BrokenLinkReporter.new(reports_dir, logger).generate_reports

    logger.info("Reports generated. Zipping...")
    system "zip #{report_zip_path} #{reports_dir}/*_broken_links.csv --junk-paths"

    logger.info("Reports zipped. Emailing to #{email_address}")
    Notifications.broken_link_reports(report_zip_path, email_address).deliver
    logger.info("Email sent.")
  rescue => e
    Airbrake.notify_or_ignore(e,
      error_message: "Exception raised during broken link report generation: '#{e.message}'")
    raise
  end
end
