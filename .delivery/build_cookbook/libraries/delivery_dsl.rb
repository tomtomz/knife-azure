#
# The pipeline name for the current project
#
# @return [String]
#
def delivery_pipeline
  change.pipeline
end

def delivery_stage
  change.stage
end