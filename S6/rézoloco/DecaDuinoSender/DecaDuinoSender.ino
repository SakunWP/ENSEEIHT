// DecaDuinoSender
// Ce croquis est un exemple d'utilisation de la librairie DecaDuino
// Il permet d'envoyer des messages avec l'interface UWB
// by Adrien van den Bossche <vandenbo@univ-tlse2.fr>
// Ce croquis fait partir du projet DecaDuino (cf. fichier DecaDuino LICENCE)

#include <SPI.h>
#include <DecaDuino.h>

#define MAX_FRAME_LEN 120
#//define MY_ADDR 34

DecaDuino decaduino;  //Interface radio UWB
uint8_t txData[MAX_FRAME_LEN]; // buffer des données émises (tableau d'octets) 
uint16_t txLen; //nombre d'octets émis <= MAC_FRAME_LEN
uint8_t txFrames; // nb de trames émises module 255


void setup()
{
  //Sélection de la LED interne connectée au pin 13 de la carte
  pinMode(13, OUTPUT); 
  Serial.begin(115200); // Init Serial port speed
  SPI.setSCK(14); // Set SPI clock pin (pin 14 on DecaWiNo board)
  
  // Initialisation de DecaDuino
  if ( !decaduino.init() ) {
    // LED 13 clignotte si init échoue
    Serial.println("decaduino init failed");
    while(1) { digitalWrite(13, HIGH); delay(50); digitalWrite(13, LOW); delay(50); }
  }

  txFrames = 1;
  decaduino.setChannel(1);
  decaduino.setTxPcode(5);
  uint8_t canal = decaduino.getChannel();
  uint8_t Pcode =decaduino.getTxPcode();
  Serial.print("canal:");
  Serial.print(canal);
  Serial.print("TxPcode:");
  Serial.print(Pcode);

  //On attend 10s avant d'emettre
  delay(5000);
}


void loop()
{
  // On allume la LED interne sur le port 13
  digitalWrite(13, HIGH);

  //Taille des données
  txLen = 10;
  int T = 101; //ms pour un debit de 6,8Mbps ( source non fiable)
  int rando = random (pow(2,10));
  delayMicroseconds(rando*T);
  // Creation de donnees fictives dans txData
  txData[1]=txFrames;
  txData[0]= 4;
  for (int i=2; i<txLen; i++) {
    txData[i] = 0;
  }
  
  // Envoi de la trame
  decaduino.pdDataRequest(txData, txLen);
  // On attend que la trame soit émise
  while ( !decaduino.hasTxSucceeded() );
  // Log du nb de trames émises
  digitalWrite(13, LOW);
  // Incremente le nb de trames emises
  ++txFrames;
  
  //affichage
  Serial.print(txFrames);
  Serial.println(',');
  // Attente de 3 secondes
  delay(1000);
}


