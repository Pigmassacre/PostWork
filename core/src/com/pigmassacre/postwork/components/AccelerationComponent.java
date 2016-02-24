package com.pigmassacre.postwork.components;

import com.badlogic.ashley.core.Component;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.utils.Pool;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class AccelerationComponent implements Component, Pool.Poolable {
    public Vector2 acceleration = new Vector2();

    @Override
    public void reset() {
        acceleration.set(Vector2.Zero);
    }
}
