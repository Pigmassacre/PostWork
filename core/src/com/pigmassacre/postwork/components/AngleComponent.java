package com.pigmassacre.postwork.components;

import com.badlogic.ashley.core.Component;
import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.utils.Pool;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class AngleComponent implements Component, Pool.Poolable {
    public float angle = 0f;
    public float speed = 5f;

    @Override
    public void reset() {
        angle = 0f;
        speed = 5f;
    }
}
