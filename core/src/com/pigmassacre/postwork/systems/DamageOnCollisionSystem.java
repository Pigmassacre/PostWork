package com.pigmassacre.postwork.systems;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.ai.msg.Telegram;
import com.pigmassacre.postwork.components.PlayerOwnedComponent;
import com.pigmassacre.postwork.components.collision.DamageOnCollisionComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.managers.GameManager;
import com.pigmassacre.postwork.systems.collision.CollisionSystem;
import com.pigmassacre.postwork.systems.supersystems.MessageHandlingSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class DamageOnCollisionSystem extends MessageHandlingSystem {

    public DamageOnCollisionSystem() {
        MessageManager.getInstance().addListeners(this,
                MessageTypes.COLLISION);
    }

    @Override
    protected void processMessage(Telegram message, float deltaTime) {
        dealDamage(message, ((CollisionSystem.CollisionData) message.extraInfo));
    }

    private void dealDamage(Telegram message, CollisionSystem.CollisionData data) {
        DamageOnCollisionComponent damage = Mappers.damageCollision.get(data.collidingEntity);

        if (damage != null) {
            PlayerOwnedComponent playerOwned = Mappers.playerOwned.get(data.collidingEntity);
            PlayerOwnedComponent playerOwnedOther = Mappers.playerOwned.get(data.otherCollidingEntity);
            if (playerOwned != null && playerOwnedOther == null) {
                Gdx.app.log("", "deelin de dmg");
                GameManager.getGame().engine.removeEntity(data.otherCollidingEntity);
            }
        }
    }

}
