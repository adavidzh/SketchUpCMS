# Tai Sakuma <sakuma@fnal.gov>

require "stringToSUNumeric"

##____________________________________________________________________________||
class LogicalPartDefiner

  def initialize geometryManager
    @geometryManager = geometryManager
    @entityDisplayer = @geometryManager.logicalPartsManager.entityDisplayer
    @eraseAfterDefine = @geometryManager.logicalPartsManager.eraseAfterDefine
  end

  def define name, children, solid, solidName, materialName
    definitions = [ ]

    children.each do |child|
      childDefinition = child[:child].definition
      next if childDefinition.nil?
      x = stringToSUNumeric(child[:translation]['x'])
      y = stringToSUNumeric(child[:translation]['y'])
      z = stringToSUNumeric(child[:translation]['z'])
      vector = Geom::Vector3d.new z, x, y
      translation = Geom::Transformation.translation vector
      rotation = child[:rotation] ? child[:rotation].transformation : Geom::Transformation.new
      transform = translation*rotation
      definitions << {:definition => childDefinition, :transform => transform, :material => nil, :name => nil}
    end

    if solid and solid.definition
      solidDefinition = solid.definition
      transform = Geom::Transformation.new
      # material = material()
      name = solidName.to_s + " "  + materialName.to_s
      definitions << {:definition => solidDefinition, :transform => transform, :material => nil, :name => name}
    end

    group = Sketchup.active_model.entities.add_group
    entities = group.entities
    definitions.each do |definition|
      instance = entities.add_instance definition[:definition], definition[:transform]
      instance.material = definition[:material] if definition[:material]
      instance.name = definition[:name] if definition[:name]
    end
    defineFromGroup name, group

  end

  def defineFromGroup name, group
    lpInstance = group.to_component
    lpInstance.name = name.to_s

    lpDefinition = lpInstance.definition
    lpDefinition.name = "lp_" + name.to_s

    moveInstanceAway(lpInstance)
    lpDefinition
  end

  def moveInstanceAway(instance)
    @entityDisplayer.display instance unless @eraseAfterDefine
    instance.erase! if @eraseAfterDefine
    instance
  end

end

##____________________________________________________________________________||
