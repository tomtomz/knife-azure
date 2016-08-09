#
# The pipeline name for the current project
#
# @return [String]
#
def demo_delivery_pipeline
  change.pipeline
end

def demo_delivery_stage
  change.stage
end