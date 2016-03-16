package com.pigmassacre.postwork.managers;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.Game;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.pigmassacre.postwork.PostWork;
import com.pigmassacre.postwork.components.*;

/**
 * Created by pigmassacre on 2016-03-16.
 */
public class GameManager {
    
    static PostWork game;

    public static PostWork getGame() {
        return game;
    }

    public static void setGame(PostWork game) {
        GameManager.game = game;
    }

}
