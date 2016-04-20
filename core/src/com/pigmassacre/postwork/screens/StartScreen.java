package com.pigmassacre.postwork.screens;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.freetype.FreeTypeFontGenerator;
import com.badlogic.gdx.scenes.scene2d.Stage;
import static com.badlogic.gdx.scenes.scene2d.actions.Actions.*;

import com.badlogic.gdx.scenes.scene2d.actions.FloatAction;
import com.badlogic.gdx.scenes.scene2d.actions.IntAction;
import com.badlogic.gdx.scenes.scene2d.actions.RunnableAction;
import com.badlogic.gdx.scenes.scene2d.actions.SizeByAction;
import com.badlogic.gdx.scenes.scene2d.ui.Container;
import com.badlogic.gdx.scenes.scene2d.ui.Label;
import com.badlogic.gdx.scenes.scene2d.ui.Table;
import com.badlogic.gdx.scenes.scene2d.ui.TextArea;
import com.pigmassacre.postwork.PostWork;
import com.pigmassacre.postwork.managers.GameManager;

/**
 * Created by pigmassacre on 2016-01-13.
 */
public class StartScreen extends AbstractScreen {

    OrthographicCamera camera;
    Stage stage;
    Table root;

    public StartScreen(PostWork game) {
        super(game);

        GameManager.setGame(game);

        camera = new OrthographicCamera(Gdx.graphics.getWidth(), Gdx.graphics.getHeight());

        stage = new Stage();
        Gdx.input.setInputProcessor(stage);

        root = new Table();
        root.setFillParent(true);
        stage.addActor(root);

        FreeTypeFontGenerator generator = new FreeTypeFontGenerator(Gdx.files.internal("fonts/vermin_vibes_1989.ttf"));
        FreeTypeFontGenerator.FreeTypeFontParameter parameter = new FreeTypeFontGenerator.FreeTypeFontParameter();
        parameter.size = 36;
        BitmapFont font12 = generator.generateFont(parameter); // font size 12 pixels
        generator.dispose(); // don't forget to dispose to avoid memory leaks!

        final Label.LabelStyle labelStyle = new Label.LabelStyle();
        labelStyle.font = font12;
        final Label label = new Label("SUPER SMASK ZERO", labelStyle);
        final FloatAction floatActionStart = new FloatAction();
        floatActionStart.setStart(1f);
        floatActionStart.setEnd(1.25f);
        final FloatAction floatActionEnd = new FloatAction();
        floatActionEnd.setStart(1.25f);
        floatActionEnd.setEnd(1f);
        RunnableAction runnableAction = new RunnableAction();
        runnableAction.setRunnable(new Runnable() {
            @Override
            public void run() {
                label.setFontScale(floatActionStart.getValue());
            }
        });
        label.addAction(forever(
            sequence(
                parallel(
                    alpha(0.8f, 1f),
                    floatActionStart,
                    runnableAction
                ),
                parallel(
                    alpha(1f, 1f),
                    floatActionStart,
                    runnableAction
                )
            )
        ));

        Container<Label> labelContainer = new Container<>();
        labelContainer.setActor(label);
        labelContainer.center();

        root.add(label);
    }

    @Override
    public void show() {

    }

    @Override
    public void render(float delta) {
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
        stage.act(delta);
        stage.draw();
    }

    @Override
    public void resize(int width, int height) {
        stage.getViewport().update(width, height, true);
    }

    @Override
    public void pause() {

    }

    @Override
    public void resume() {

    }

    @Override
    public void hide() {

    }

    @Override
    public void dispose() {
        stage.dispose();
    }

}
