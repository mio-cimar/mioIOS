//
//  Common.h
//  MIO
//
//  Created by Ronny Libardo on 10/8/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <FirebaseAnalytics/FirebaseAnalytics.h>

//Importaciones Globales
#import <SDiPhoneVersion/SDiPhoneVersion.h>

//Métricas Usadas en la Aplicación
#define MENU_PRINCIPAL_ANCHO 230.0

//Colores Usados en la Aplicación
#define COLOR_ALEATORIO [UIColor colorWithRed:(random()%255)/255.0 green:(random()%255)/255.0 blue:(random()%255)/255.0 alpha:1]
#define COLOR_FONDO_GRIS [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1.0]
#define COLOR_FONDO_GRIS_SUAVE [UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1.0]
#define COLOR_AZUL_SUAVE [UIColor colorWithRed:0/255.0 green:176/255.0 blue:255/255.0 alpha:1.0]
#define COLOR_AZUL_BARRA_DE_ESTADO [UIColor colorWithRed:82.0/255.0 green:192.0/255.0 blue:222.0/255.0 alpha:1]
#define COLOR_BLANCO [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0]
#define COLOR_SIN_COLOR [UIColor clearColor]

//Enumeraciones
typedef enum {
    MIOZonaDePronosticoNortePacificoNorte,
    MIOZonaDePronosticoCentroPacificoNorte,
    MIOZonaDePronosticoSurPacificoNorte,
    MIOZonaDePronosticoPuntarenas,
    MIOZonaDePronosticoPacificoCentral,
    MIOZonaDePronosticoPacificoSur,
    MIOZonaDePronosticoCaribe,
    MIOZonaDePronosticoIslaDelCoco,
    MIOZonaDePronosticoCantidadDeZonas
} MIOZonaDePronostico;

typedef enum {
    MIOPronosticoRegionalDeOleaje,
    MIOPronosticoRegionalDeCorrientesMarinas,
    MIOPronosticoRegionalDeTemperaturaSuperficialDelMar,
    MIOPronosticoRegionalCantidad
} MIOPronosticoRegional;

typedef enum {
    MIOZonaMareasGolfoElena,
    MIOZonaMareasBahiaCulebra,
    MIOZonaMareasPuntarenas,
    MIOZonaMareasPuertoHerradura,
    MIOZonaMareasQuepos,
    MIOZonaMareasBahiaUvita,
    MIOZonaMareasGolfito,
    MIOZonaMareasLimon,
    MIOZonaMareasIslaDelCoco,
    MIOZonaMareasCantidadDeZonas
} MIOZonaMareas;


typedef NS_ENUM(NSInteger, MIOSettingsLanguages) {
    MIOSettingsLanguageSpanish,
    MIOSettingsLanguageEnglish
};

typedef NS_ENUM(NSInteger, MIOSettingsHeightMeasureUnits) {
    MIOSettingsHeightMeasureUnitMeters,
    MIOSettingsHeightMeasureUnitFeet
};

typedef NS_ENUM(NSInteger, MIOSettingsSpeedMeasureUnits) {
    MIOSettingsSpeedMeasureUnitKilometers,
    MIOSettingsSpeedMeasureUnitKnots
};

#define PRONOSTICO_VALOR_VIENTO @"valorViento"
#define PRONOSTICO_DIRECCION_VIENTO @"direccionDeViento"
#define PRONOSTICO_ALTURA_OLA @"alturaDeOla"
#define PRONOSTICO_ALTURA_MAXIMA_OLA @"alturaMaximaDeOla"
#define PRONOSTICO_DIRECCION_OLA @"direccionDeOla"
#define PRONOSTICO_PERIODO_OLA @"periodoDeOla"
#define PRONOSTICO_HORA @"horaDePronostico"

//Contantes para el uso del API
#define API_ROOT @"http://www.miocimar.ucr.ac.cr/"
#define API_POST_NODE @"api/taxonomy/selectNodes"
#define API_GET_NODE @"api/node/"
#define API_CSV_LOCATION @"sites/default/files/csvs/"
#define API_PDF_LOCATION @"sites/default/files/pdfs/"
#define API_GIF_REGIONAL_LOCATION @"sites/default/files/gifs/"

//Identificadores de nodos
#define NID_PRONLOV_NPN 1
#define NID_PRONLOV_CPN 2
#define NID_PRONLOV_SPN 3
#define NID_PRONLOV_PUN 4
#define NID_PRONLOV_PCE 5
#define NID_PRONLOV_PSU 6
#define NID_PRONLOV_CAR 7
#define NID_PRONLOV_ICO 8

#define NID_PROREG_OLEAJE 10
#define NID_PROREG_CORMAR 11
#define NID_PROREG_TEMSUP 12

#define NID_PREDMAR_GOEL 13
#define NID_PREDMAR_BACU 14
#define NID_PREDMAR_PUNT 15
#define NID_PREDMAR_PUHE 16
#define NID_PREDMAR_QUEP 17
#define NID_PREDMAR_BAUV 18
#define NID_PREDMAR_GOLF 19
#define NID_PREDMAR_LIMO 20
#define NID_PREDMAR_ISCO 21

#define API_ADVER 22

//Macros para detectar tipo de dispotivo
#define ES_DISPOSITIVO_ANGOSTO ([SDiPhoneVersion deviceSize] == iPhone35inch || [SDiPhoneVersion deviceSize] == iPhone4inch)
#define ES_DISPOSITIVO_CORTO ([SDiPhoneVersion deviceSize] == iPhone35inch)

//Macros varias
#define RADIANES_A_GRADOS(radianes) ((radianes) * (180.0 / M_PI))
#define GRADOS_A_RADIANES(grados) ((grados * M_PI) / 180.0)

//Constantes globales
#define MAXIMO_NUMERO_ADVERTENCIAS 10
extern NSString *const APIURL;

extern NSString *const kMIOHeightMeasureUnitKey;
extern NSString *const kMIOSpeedMeasureUnitKey;
extern NSString *const kMIOLanguageKey;
extern NSString *const kMIONotificationsEnabledKey;
extern NSString *const kMIOLanguageModifiedKey;

extern double kMeterMultiplier;
extern double kFeetMultiplier;
extern double kKnotMultiplier;
extern double kKilometersMultiplier;

extern double kFirstWindRange;
extern double kSecondWindRange;
extern double kThirdWindRange;

extern double kFirstWaveRange;
extern double kSecondWaveRange;
extern double kThirdWaveRange;

@interface Common : NSObject

@end
