require_relative "./injest.rb"

# Download, parse, and write XML data to the database for this project.
# Usage:
#
#   rails runner lib/injest_all_files.rb
#

# I'm just proving the HTTP link to the files for the purpose of this exercise. In production, I'd
# generally want to download and cache the files somewhere to prevent unecessary network work.
Injest.injest_files([
  "https://filing-service.s3-us-west-2.amazonaws.com/990-xmls/201612429349300846_public.xml",
  "https://filing-service.s3-us-west-2.amazonaws.com/990-xmls/201831309349303578_public.xml",
  "https://filing-service.s3-us-west-2.amazonaws.com/990-xmls/201641949349301259_public.xml",
  "https://filing-service.s3-us-west-2.amazonaws.com/990-xmls/201921719349301032_public.xml",
  "https://filing-service.s3-us-west-2.amazonaws.com/990-xmls/202141799349300234_public.xml",
  "https://filing-service.s3-us-west-2.amazonaws.com/990-xmls/201823309349300127_public.xml",
  "https://filing-service.s3-us-west-2.amazonaws.com/990-xmls/202122439349100302_public.xml", # small file
  "https://filing-service.s3-us-west-2.amazonaws.com/990-xmls/201831359349101003_public.xml", # no recipient tables
])
