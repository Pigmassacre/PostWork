package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.gdx.math.MathUtils;
import com.pigmassacre.postwork.components.AngleComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class AngleSystem extends IteratingSystem {

    public AngleSystem() {
        super(Family.all(AngleComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final AngleComponent angle = Mappers.angle.get(entity);

        angle.angle = MathUtils.lerpAngle(angle.angle, angle.desiredAngle, MathUtils.clamp(deltaTime * 16f, 0f, 1f));
    }

}
