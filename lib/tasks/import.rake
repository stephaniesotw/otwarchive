namespace :import   do

desc "Test import run"
task(:test => :environment) do
  nmi = MassImportTool.new
  nmi.import_data
end
end