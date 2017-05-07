package com.pigmassacre.postwork.components;

import com.badlogic.ashley.core.Component;
import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.utils.Pool;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class OwnerComponent implements Component, Pool.Poolable {
    public Entity owner = null;

    @Override
    public void reset() {
        owner = null;
    }
}
