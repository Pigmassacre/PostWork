package com.pigmassacre.postwork;

import com.badlogic.ashley.core.PooledEngine;
import com.badlogic.gdx.Game;
import com.badlogic.gdx.Gdx;
import com.pigmassacre.postwork.screens.GameScreen;
import com.pigmassacre.postwork.screens.StartScreen;

public class PostWork extends Game {

    public PooledEngine engine;

	@Override
	public void create () {
        engine = new PooledEngine();
        //setScreen(new StartScreen(this));
		setScreen(new GameScreen(this));
	}

	@Override
	public void render () {
        getScreen().render(Gdx.graphics.getDeltaTime());
	}

    @Override
    public void dispose() {
        super.dispose();
    }

}
