namespace :import   do

desc "Test import run"
task(:test) do
  nmi = MassImportTool.New
  nmi.import_data
end
end