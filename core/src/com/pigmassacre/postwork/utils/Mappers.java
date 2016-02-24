package com.pigmassacre.postwork.utils;

import com.badlogic.ashley.core.ComponentMapper;
import com.pigmassacre.postwork.components.*;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class Mappers {
    public static final ComponentMapper<PositionComponent> position = ComponentMapper.getFor(PositionComponent.class);
    public static final ComponentMapper<PlayerControllerComponent> playerController = ComponentMapper.getFor(PlayerControllerComponent.class);
    public static final ComponentMapper<VelocityComponent> velocity = ComponentMapper.getFor(VelocityComponent.class);
    public static final ComponentMapper<AccelerationComponent> acceleration = ComponentMapper.getFor(AccelerationComponent.class);
    public static final ComponentMapper<VisualComponent> visual = ComponentMapper.getFor(VisualComponent.class);
    public static final ComponentMapper<CollisionComponent> collision = ComponentMapper.getFor(CollisionComponent.class);
}
