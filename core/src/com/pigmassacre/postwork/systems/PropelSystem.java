package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.gdx.math.MathUtils;
import com.pigmassacre.postwork.components.AccelerationComponent;
import com.pigmassacre.postwork.components.AngleComponent;
import com.pigmassacre.postwork.components.PropelComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class PropelSystem extends IteratingSystem {

    public PropelSystem() {
        super(Family.all(AngleComponent.class, AccelerationComponent.class, PropelComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final AngleComponent angle = Mappers.angle.get(entity);
        final PropelComponent propel = Mappers.propel.get(entity);
        final AccelerationComponent acceleration = Mappers.acceleration.get(entity);

        acceleration.acceleration.x = MathUtils.cos(angle.angle) * propel.speed * deltaTime;
        acceleration.acceleration.y = MathUtils.sin(angle.angle) * propel.speed * deltaTime;
    }

}
