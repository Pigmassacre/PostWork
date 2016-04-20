package com.pigmassacre.postwork.components;

import com.badlogic.ashley.core.Component;
import com.badlogic.gdx.utils.Pool;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class HealthComponent implements Component, Pool.Poolable {
    public float health = 0f;

    @Override
    public void reset() {
        health = 0f;
    }
}
