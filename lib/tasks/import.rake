namespace :import   do

desc "Test import run"
task(:test => :environment) do
  nmi = MassImportTool.New
  nmi.import_data
end
end