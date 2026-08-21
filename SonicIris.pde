import ddf.minim.analysis.*;
import ddf.minim.*;
import java.io.File;

Minim minim;
AudioPlayer jingle;
FFT fftLin;

float xPos = 0;
float yPos = 0;

float angle = 0;

float r = 200;
float j = 0;
float ri = 0;

int fftSize = 2048;

float totalBlocks;
float angleincrease;
float angleStep = TWO_PI * 0.61803398875;

ArrayList<float[]> fftQueue = new ArrayList<float[]>();

boolean audioLoaded = false;

String jpgPath = "";


// =====================================================
// SETUP
// =====================================================

void setup()
{
  size(700, 700);

  minim = new Minim(this);

  background(0);

  // Abrir selector de archivo
  selectInput(
    "Selecciona un archivo de audio:",
    "fileSelected"
  );
}


// =====================================================
// SELECCIÓN DEL ARCHIVO
// =====================================================

void fileSelected(File selection)
{
  if (selection == null)
  {
    println("No se seleccionó ningún archivo.");
    exit();
    return;
  }

  println("Archivo seleccionado:");
  println(selection.getAbsolutePath());


  // Cargar audio
  jingle = minim.loadFile(
    selection.getAbsolutePath(),
    fftSize
  );


  if (jingle == null)
  {
    println("No se pudo cargar el archivo.");
    exit();
    return;
  }


  // FFT
  fftLin = new FFT(
    fftSize,
    jingle.sampleRate()
  );


  // Radio
  ri = r / fftLin.specSize();


  // Número de muestras aproximadas
  float totalSamples =
    (jingle.length() / 1000.0) *
    jingle.sampleRate();


  // Número de ventanas FFT
  totalBlocks =
    totalSamples / fftSize;


  // Incremento adicional
  angleincrease =
    TWO_PI / totalBlocks;


  println("--------------------------------");
  println("Archivo: " + selection.getName());
  println("Sample rate: " + jingle.sampleRate());
  println("FFT size: " + fftSize);
  println("Duración: " + jingle.length() + " ms");
  println("Bloques FFT: " + totalBlocks);
  println("Angle increase: " +
          degrees(angleincrease) + "°");
  println("--------------------------------");
  
  String songName = selection.getName();

  // Quitar extensión
  int dot = songName.lastIndexOf('.');
  
  if (dot > 0)
  {
    songName = songName.substring(0, dot);
  }
  
  // Guardar en el directorio del proyecto de Processing
  jpgPath =
    sketchPath() +
    File.separator +
    songName +
    "_eye_spectrum.png";
  
  println("PNG: " + jpgPath);


  // Listener
  MyAudioListener listener =
    new MyAudioListener();

  jingle.addListener(listener);


  audioLoaded = true;

  // Reproducir
  jingle.play();
}


// =====================================================
// AUDIO LISTENER
// =====================================================

class MyAudioListener implements AudioListener
{
  void samples(float[] samp)
  {
    processBuffer(samp);
  }


  void samples(float[] left, float[] right)
  {
    processBuffer(left);
  }


  void processBuffer(float[] buffer)
  {
    FFT fft = new FFT(
      fftSize,
      jingle.sampleRate()
    );

    fft.forward(buffer);


    float[] spectrum =
      new float[fft.specSize()];


    for (int i = 0; i < fft.specSize(); i++)
    {
      spectrum[i] =
        fft.getBand(i);
    }


    synchronized(fftQueue)
    {
      fftQueue.add(spectrum);
    }
  }
}


// =====================================================
// DRAW
// =====================================================

void draw()
{
  if (!audioLoaded)
    return;


  float[] spectrum = null;


  synchronized(fftQueue)
  {
    if (fftQueue.size() > 0)
    {
      spectrum =
        fftQueue.remove(0);
    }
  }


  if (spectrum == null)
    return;


  // ---------------------------------
  // DIBUJAR UNA LÍNEA
  // ---------------------------------

  pushMatrix();

  translate(width / 2, height / 2);

  j = r;


  for (int i = spectrum.length - 250;
       i > 0;
       i--)
  {
    stroke(
      #451800,
      constrain(
        spectrum[i] * 8,
        0,
        255
      )
    );


    xPos = j * cos(angle);
    yPos = j * sin(angle);


    point(xPos, yPos);


    j -= ri;
  }


  popMatrix();


  // ---------------------------------
  // ÁNGULO
  // ---------------------------------

  // IMPORTANTE:
  // mantenemos los 72 RADIANES de tu código original

  //angle += 72 + angleincrease;
  angle += angleStep;


  if (angle > TWO_PI)
    angle -= TWO_PI;
}


// =====================================================
// STOP
// =====================================================

void stop()
{
  if (jingle != null)
    jingle.close();

  if (minim != null)
    minim.stop();

  super.stop();
}

void exit()
{
// always close Minim audio classes when you are done with them
  jingle.close();
  // always stop Minim before exiting
  minim.stop();
  //super.stop();
  save(jpgPath);
}
