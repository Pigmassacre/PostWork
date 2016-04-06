package com.pigmassacre.postwork.components;

import com.badlogic.ashley.core.Component;
import com.badlogic.gdx.utils.Pool;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class ShootingComponent implements Component, Pool.Poolable {

    public boolean shooting = false;
    public float timeSinceLastShot = 0f;

    @Override
    public void reset() {
        shooting = false;
        timeSinceLastShot = 0f;
    }
}
