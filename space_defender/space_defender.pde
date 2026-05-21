import processing.sound.*;

int estadoJogo = 0;
float volume = 0.5; 
boolean opcaoEFGH = false; 
int recorde = 0;

PImage imgTituloMenu;
PImage imgTituloOptions; 
Botao btnPlay, btnConfig, btnTrofeu, btnFechar;
BotaoSimples btnBack; 

PImage imgBarraFundo, imgBarraPinoSheet, imgIconMusica;
PImage pinoNormal, pinoHover, pinoClicado;
boolean musicaMutada = false;

float sliderX = 255;  
float sliderY = 165;  
float sliderW = 150; 

float iconMusicaX = 210; 
float iconMusicaY = 165;

float x, y;
PImage sheet, imgParado, imgEsquerda, imgDireita, imgAtual;
PImage imgFundo;
float fundoY = 0; 
float inimigoX, inimigoY;
int pontos = 0;
int vidas = 3; 

PImage imgAsteroide, imgAsteroidePequeno, asteroideAtual;
PImage[] imgHits = new PImage[4];

ArrayList<Tiro> tiros = new ArrayList<Tiro>();
ArrayList<Explosao> explosoes = new ArrayList<Explosao>(); 

SoundFile somTiro, somExplosao, musicaFundo;

boolean indoEsquerda = false;
boolean indoDireita = false;

void setup() {
  size(600, 400);
  noSmooth(); 

  x = width / 2;
  y = height - 60;

  imgFundo = loadImage("fundo.png");
  sheet = loadImage("player_sheet.png");
  imgTituloMenu = loadImage("titulo.png"); 
  imgTituloOptions = loadImage("options_icon.png"); 
  btnBack = new BotaoSimples(165, 320, loadImage("icon_back.png")); 

  imgAsteroide = loadImage("asteroid.png");
  imgAsteroidePequeno = loadImage("asteroid-small.png");
  
  imgHits[0] = loadImage("hit1.png");
  imgHits[1] = loadImage("hit2.png");
  imgHits[2] = loadImage("hit3.png");
  imgHits[3] = loadImage("hit4.png");

  imgBarraFundo = loadImage("barra_fundo.png"); 
  imgBarraPinoSheet = loadImage("barra_pino.png"); 
  imgIconMusica = loadImage("sound_icon.png"); 
  
  if (imgBarraPinoSheet != null) {
    int hPino = imgBarraPinoSheet.height / 3; 
    int wPino = imgBarraPinoSheet.width;
    pinoNormal  = imgBarraPinoSheet.get(0, 0, wPino, hPino);
    pinoHover   = imgBarraPinoSheet.get(0, hPino, wPino, hPino);
    pinoClicado = imgBarraPinoSheet.get(0, hPino * 2, wPino, hPino);
  }

  try {
    somTiro = new SoundFile(this, "tiro.wav");
    somExplosao = new SoundFile(this, "explosao.wav");
    musicaFundo = new SoundFile(this, "musica.mp3");
    musicaFundo.loop();
    musicaFundo.amp(volume);
  } catch (Exception e) { println("Erro nos sons"); }

  btnPlay = new Botao(width/2, 210, loadImage("botao_play.png"));
  int yIcones = 320;
  btnConfig = new Botao(width/2 - 125, yIcones, loadImage("icon_config.png")); 
  btnTrofeu = new Botao(width/2, yIcones, loadImage("icon_trofeu.png"));
  btnFechar = new Botao(width/2 + 125, yIcones, loadImage("icon_fechar.png"));

  if (sheet != null) {
    int w = sheet.width / 3;
    int h = sheet.height;
    imgEsquerda = sheet.get(0, 0, w, h);
    imgParado   = sheet.get(w, 0, w, h);
    imgDireita  = sheet.get(w * 2, 0, w, h);
    imgAtual = imgParado;
  }

  carregarRecorde(); 
  resetInimigo();
}

void draw() {
  background(0);
  desenharFundo();

  if (estadoJogo == 0) {
    desenharMenuPrincipal();
  } else if (estadoJogo == 1) {
    jogar();
  } else if (estadoJogo == 2) {
    desenharConfiguracoes();
  } else if (estadoJogo == 3) {
    desenharTelaRecorde();
  }
}

void desenharMenuPrincipal() {
  imageMode(CENTER);
  if (imgTituloMenu != null) image(imgTituloMenu, width/2, 90, 300, 120); 
  btnPlay.display(180, 80);    
  btnConfig.display(90, 90);   
  btnTrofeu.display(90, 90);
  btnFechar.display(90, 90);
}

void carregarRecorde() {
  String[] linhas = loadStrings("data/recorde.txt");
  if (linhas != null && linhas.length > 0) {
    recorde = int(linhas[0]);
  } else {
    recorde = 0;
  }
}

void checarESalvarRecorde() {
  if (pontos > recorde) {
    recorde = pontos;
    String[] dados = { str(recorde) };
    saveStrings("data/recorde.txt", dados);
  }
}

void desenharTelaRecorde() {
  pushStyle();
  rectMode(CENTER);
  noStroke();

  float boxW = 350;
  float boxH = 220; 
  float boxX = width/2;
  float boxY = height/2 - 20;
  float bThick = 15; 

  fill(#081c3c);
  rect(boxX, boxY, boxW, boxH);

  rectMode(CORNER);
  fill(#fcf4a3); rect(boxX - boxW/2 + bThick, boxY - boxH/2, boxW - bThick*2, bThick);
  fill(#f39c12); rect(boxX - boxW/2 + bThick, boxY + boxH/2 - bThick, boxW - bThick*2, bThick);
  fill(#5ba3cf); rect(boxX - boxW/2, boxY - boxH/2 + bThick, bThick, boxH - bThick*2);
  rect(boxX + boxW/2 - bThick, boxY - boxH/2 + bThick, bThick, boxH - bThick*2);

  fill(#4a7c9f);
  rect(boxX - boxW/2, boxY - boxH/2, bThick, bThick);
  rect(boxX + boxW/2 - bThick, boxY - boxH/2, bThick, bThick);
  rect(boxX - boxW/2, boxY + boxH/2 - bThick, bThick, bThick);
  rect(boxX + boxW/2 - bThick, boxY + boxH/2 - bThick, bThick, bThick);
  popStyle();
  
  textAlign(CENTER, CENTER);
  fill(255); textSize(28);
  text("HIGH SCORE", width/2, height/2 - 60);
  
  fill(#ff9900); textSize(56);
  text(recorde, width/2, height/2 + 10);

  // Botão voltar
  btnBack.x = width/2; 
  btnBack.y = 330;
  btnBack.display(100, 35); 
}

void desenharConfiguracoes() {
  pushStyle();
  rectMode(CENTER);
  noStroke();

  float boxW = 450;
  float boxH = 320; 
  float boxX = width/2;
  float boxY = height/2;
  float bThick = 20; 

  fill(#081c3c);
  rect(boxX, boxY, boxW, boxH);

  rectMode(CORNER);
  fill(#fcf4a3); 
  rect(boxX - boxW/2 + bThick, boxY - boxH/2, boxW - bThick*2, bThick);
  fill(#f39c12); 
  rect(boxX - boxW/2 + bThick, boxY + boxH/2 - bThick, boxW - bThick*2, bThick);
  fill(#5ba3cf); 
  rect(boxX - boxW/2, boxY - boxH/2 + bThick, bThick, boxH - bThick*2);
  rect(boxX + boxW/2 - bThick, boxY - boxH/2 + bThick, bThick, boxH - bThick*2);

  fill(#4a7c9f);
  rect(boxX - boxW/2, boxY - boxH/2, bThick, bThick);
  rect(boxX + boxW/2 - bThick, boxY - boxH/2, bThick, bThick);
  rect(boxX - boxW/2, boxY + boxH/2 - bThick, bThick, bThick);
  rect(boxX + boxW/2 - bThick, boxY + boxH/2 - bThick, bThick, bThick);
  popStyle();
  
  imageMode(CENTER);
  
  if (imgTituloOptions != null) {
    image(imgTituloOptions, width/2, 90, imgTituloOptions.width * 2, imgTituloOptions.height * 2); 
  }
  
  if (imgIconMusica != null) {
    image(imgIconMusica, iconMusicaX, iconMusicaY, 34, 34); 
  }
  
  if (musicaMutada) {
    stroke(#ff3333); strokeWeight(4);
    line(iconMusicaX - 12, iconMusicaY - 12, iconMusicaX + 12, iconMusicaY + 12);
    line(iconMusicaX + 12, iconMusicaY - 12, iconMusicaX - 12, iconMusicaY + 12);
  }
  
  if (imgBarraFundo != null) {
    image(imgBarraFundo, sliderX + (sliderW / 2), sliderY, sliderW + 20, 20); 
  }
  
  float pinoX = sliderX + (volume * sliderW);
  PImage pinoAtual = pinoNormal;
  if (mouseX > pinoX - 12 && mouseX < pinoX + 12 && mouseY > sliderY - 15 && mouseY <= sliderY + 15) {
    pinoAtual = mousePressed ? pinoClicado : pinoHover;
  }
  
  if (pinoAtual != null) image(pinoAtual, pinoX, sliderY, 18, 24); 
  
  stroke(#66a3ff); strokeWeight(3);
  rectMode(CENTER); 
  
  float caixaY = 245; 

  if (!opcaoEFGH) fill(#3366cc); else fill(#081c3c);
  rect(width/2 - 80, caixaY, 36, 36, 4); 
  
  textAlign(LEFT, CENTER); textSize(18); fill(255); 
  text("ABCD", width/2 - 50, caixaY - 3);
  
  if (opcaoEFGH) fill(#3366cc); else fill(#081c3c);
  rect(width/2 + 50, caixaY, 36, 36, 4); 
  
  textAlign(LEFT, CENTER); fill(255); 
  text("EFGH", width/2 + 80, caixaY - 3);
  
  textAlign(CENTER, CENTER); 
  fill(#ff9900); noStroke();
  if (!opcaoEFGH) text("✔", width/2 - 80, caixaY - 3); 
  else text("✔", width/2 + 50, caixaY - 3);

  btnBack.x = width/2; 
  btnBack.y = 310;
  btnBack.display(100, 35); 
}

void controlarSlider() {
  if (mouseX >= sliderX && mouseX <= sliderX + sliderW && mouseY >= sliderY - 15 && mouseY <= sliderY + 15) {
    volume = constrain((mouseX - sliderX) / sliderW, 0.0, 1.0);
    atualizarVolumeReal();
  }
}

void atualizarVolumeReal() {
  if (musicaFundo != null) {
    if (musicaMutada) musicaFundo.amp(0);
    else musicaFundo.amp(volume);
  }
}

void mousePressed() {
  if (estadoJogo == 0) {
    if (btnPlay.checarMouse(180, 80)) btnPlay.pressionado = true;
    if (btnConfig.checarMouse(90, 90)) btnConfig.pressionado = true;
    if (btnTrofeu.checarMouse(90, 90)) btnTrofeu.pressionado = true;
    if (btnFechar.checarMouse(90, 90)) btnFechar.pressionado = true;
  } 
  else if (estadoJogo == 2) {
    if (btnBack.checarMouse(100, 35)) btnBack.pressionado = true;
    
    if (mouseX >= iconMusicaX - 20 && mouseX <= iconMusicaX + 20 && mouseY >= iconMusicaY - 20 && mouseY <= iconMusicaY + 20) {
      musicaMutada = !musicaMutada;
      atualizarVolumeReal();
    }
    
    controlarSlider(); 
    
    if (mouseX > width/2 - 98 && mouseX < width/2 - 62 && mouseY > 227 && mouseY < 263) opcaoEFGH = false;
    if (mouseX > width/2 + 32 && mouseX < width/2 + 68 && mouseY > 227 && mouseY < 263) opcaoEFGH = true;
  }
  else if (estadoJogo == 3) {
    if (btnBack.checarMouse(100, 35)) btnBack.pressionado = true;
  }
}

void mouseDragged() {
  if (estadoJogo == 2) controlarSlider(); 
}

void mouseReleased() {
  if (estadoJogo == 0) {
    if (btnPlay.pressionado && btnPlay.checarMouse(180, 80)) {
      estadoJogo = 1;
      vidas = 3;
      pontos = 0;
      x = width / 2;
      resetInimigo();
      tiros.clear();
      explosoes.clear();
    }
    if (btnConfig.pressionado && btnConfig.checarMouse(90, 90)) estadoJogo = 2; 
    if (btnTrofeu.pressionado && btnTrofeu.checarMouse(90, 90)) estadoJogo = 3; 
    if (btnFechar.pressionado && btnFechar.checarMouse(90, 90)) exit();
  } 
  else if (estadoJogo == 2 || estadoJogo == 3) {
    if (btnBack.pressionado && btnBack.checarMouse(100, 35)) estadoJogo = 0;
  }
  btnPlay.pressionado = btnConfig.pressionado = btnTrofeu.pressionado = btnFechar.pressionado = false;
  if (btnBack != null) btnBack.pressionado = false;
}

void jogar() {
  imgAtual = imgParado;
  if (indoEsquerda && x > 25) { x -= 5; imgAtual = imgEsquerda; }
  if (indoDireita && x < width - 25) { x += 5; imgAtual = imgDireita; }

  imageMode(CENTER);
  if (imgAtual != null) image(imgAtual, x, y, 50, 50);
  
  if (asteroideAtual != null) image(asteroideAtual, inimigoX, inimigoY);
  
  inimigoY += 3;
  if (inimigoY > height + 50) resetInimigo();

  for (int i = explosoes.size() - 1; i >= 0; i--) {
    Explosao e = explosoes.get(i);
    e.display();
    if (e.terminou) explosoes.remove(i);
  }

  for (int i = tiros.size() - 1; i >= 0; i--) {
    Tiro t = tiros.get(i);
    t.update(); t.display();
    if (dist(t.x, t.y, inimigoX, inimigoY) < 30) {
      pontos++;
      if (somExplosao != null) somExplosao.play();
      explosoes.add(new Explosao(inimigoX, inimigoY)); 
      tiros.remove(i); 
      resetInimigo();
    }
  }
  
  if (dist(x, y, inimigoX, inimigoY) < 40) {
    vidas--;
    if (somExplosao != null) somExplosao.play();
    explosoes.add(new Explosao(x, y)); 
    resetInimigo();
    
    if (vidas <= 0) {
      checarESalvarRecorde(); 
      estadoJogo = 0; 
    }
  }
  
  fill(255); textSize(20); textAlign(LEFT);
  text("Pontos: " + pontos, 20, 30);
  text("Vidas: " + vidas, 20, 55);
}

void desenharFundo() {
  if (imgFundo != null) {
    imageMode(CORNER);
    
    fundoY += 2;
    if (fundoY >= imgFundo.height) {
      fundoY = 0;
    }
    
    for (int i = 0; i < width; i += imgFundo.width) {
      for (int j = -imgFundo.height; j < height; j += imgFundo.height) { 
        image(imgFundo, i, j + fundoY); 
      }
    }
  }
}

void keyPressed() {
  if (keyCode == LEFT)  indoEsquerda = true;
  if (keyCode == RIGHT) indoDireita = true;
  if (key == ' ' && estadoJogo == 1) {
    tiros.add(new Tiro(x, y - 20));
    if (somTiro != null) somTiro.play();
  }
}

void keyReleased() {
  if (keyCode == LEFT)  indoEsquerda = false;
  if (keyCode == RIGHT) indoDireita = false;
}

void resetInimigo() { 
  inimigoX = random(40, width - 40); 
  inimigoY = -50; 
  if (random(1) > 0.5) {
    asteroideAtual = imgAsteroide;
  } else {
    asteroideAtual = imgAsteroidePequeno;
  }
}

class Explosao {
  float x, y;
  int frameAtual = 0;
  int timer = 0;
  int delay = 4;
  boolean terminou = false;

  Explosao(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void display() {
    if (frameAtual < 4 && imgHits[frameAtual] != null) {
      imageMode(CENTER);
      image(imgHits[frameAtual], x, y);
      timer++;
      if (timer >= delay) {
        frameAtual++;
        timer = 0;
      }
    } else {
      terminou = true;
    }
  }
}

class Botao {
  float x, y; int wOrig, hOrig; PImage normal, hover, clicado; boolean pressionado = false;
  Botao(float x, float y, PImage sheetOriginal) {
    this.x = x; this.y = y;
    if (sheetOriginal != null) {
      this.wOrig = sheetOriginal.width / 3; this.hOrig = sheetOriginal.height;
      this.normal  = sheetOriginal.get(0, 0, wOrig, hOrig);     
      this.hover   = sheetOriginal.get(wOrig, 0, wOrig, hOrig);     
      this.clicado = sheetOriginal.get(wOrig * 2, 0, wOrig, hOrig); 
    }
  }
  void display(float l, float a) {
    boolean mouseEmCima = checarMouse(l, a); imageMode(CENTER); PImage atual = normal;
    if (pressionado && mouseEmCima) atual = clicado; else if (mouseEmCima) atual = hover;
    if (atual != null) image(atual, x, y, l, a);
  }
  boolean checarMouse(float l, float a) { return (mouseX > x - l/2 && mouseX < x + l/2 && mouseY > y - a/2 && mouseY < y + a/2); }
}

class BotaoSimples {
  float x, y; PImage img; boolean pressionado = false;
  BotaoSimples(float x, float y, PImage img) { this.x = x; this.y = y; this.img = img; }
  void display(float l, float a) {
    imageMode(CENTER);
    if (pressionado && checarMouse(l, a)) tint(180); else if (checarMouse(l, a)) tint(220); else noTint();
    if (img != null) image(img, x, y, l, a); noTint();
  }
  boolean checarMouse(float l, float a) { return (mouseX > x - l/2 && mouseX < x + l/2 && mouseY > y - a/2 && mouseY < y + a/2); }
}

class Tiro {
  float x, y; Tiro(float nx, float ny) { x = nx; y = ny; }
  void update() { y -= 10; }
  void display() { fill(0, 255, 255); noStroke(); rectMode(CENTER); rect(x, y, 4, 15); }
}
