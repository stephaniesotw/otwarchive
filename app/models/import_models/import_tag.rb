#Used with mass importer
class ImportTag < Struct.new(:old_id,:new_id,:tag,:tag_type,:old_parent_id,:new_parent_id)
end