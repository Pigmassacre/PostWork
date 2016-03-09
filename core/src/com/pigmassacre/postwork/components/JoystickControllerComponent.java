package com.pigmassacre.postwork.components;

import com.badlogic.ashley.core.Component;
import com.badlogic.gdx.utils.Pool;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class JoystickControllerComponent implements Component, Pool.Poolable {
    public float[] axes = new float[12];

    @Override
    public void reset() {
        axes = new float[12];
    }
}
