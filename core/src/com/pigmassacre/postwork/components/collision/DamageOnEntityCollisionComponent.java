package com.pigmassacre.postwork.components.collision;

import com.badlogic.ashley.core.Component;
import com.badlogic.gdx.utils.Pool;

/**
 * Created by pigmassacre on 2016-02-03.
 */
public class DamageOnEntityCollisionComponent implements Component, Pool.Poolable {
    public float damage = 0f;

    @Override
    public void reset() {
        damage = 0f;
    }
}
