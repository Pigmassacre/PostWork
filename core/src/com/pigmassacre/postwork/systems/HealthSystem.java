package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.gdx.math.MathUtils;
import com.pigmassacre.postwork.components.AccelerationComponent;
import com.pigmassacre.postwork.components.AngleComponent;
import com.pigmassacre.postwork.components.HealthComponent;
import com.pigmassacre.postwork.components.PropelComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class HealthSystem extends IteratingSystem {

    public HealthSystem() {
        super(Family.all(HealthComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        HealthComponent healthComponent = Mappers.health.get(entity);
        if (healthComponent.health <= 0) {
            // TODO: Just removing might be wrong but it should be destroyed at least
            getEngine().removeEntity(entity);
        }
    }

}
