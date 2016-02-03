package com.pigmassacre.postwork.utils;

import com.badlogic.ashley.core.ComponentMapper;
import com.pigmassacre.postwork.components.CollisionComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.components.VisualComponent;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class Mappers {
    public static final ComponentMapper<PositionComponent> position = ComponentMapper.getFor(PositionComponent.class);
    public static final ComponentMapper<VisualComponent> visual = ComponentMapper.getFor(VisualComponent.class);
    public static final ComponentMapper<CollisionComponent> collision = ComponentMapper.getFor(CollisionComponent.class);
}
