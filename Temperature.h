#ifndef TEMPERATURE_H
#define TEMPERATURE_H

// Structure pour un point de la grille (noeud de liste chaînée)
typedef struct GridPoint {
    int x;                      // Position x dans la grille
    int y;                      // Position y dans la grille
    
    double temperature;         // Température actuelle
    double new_temperature;     // Nouvelle température (pour mise à jour)
    struct GridPoint *next;     // Pointeur vers le prochain point
} GridPoint;

// Structure pour une source thermique
typedef struct {
    int x;                      // Position x
    int y;                      // Position y
    double power;               // Puissance thermique (positive pour chaleur, négative pour froid)
    int radius;                 // Rayon d'influence
    int active;                 // 1 si actif, 0 sinon
} HeatSource;

// Structure pour la grille complète
typedef struct {
    GridPoint *head;            // Tête de la liste chaînée
    int width;                  // Largeur de la grille
    int height;                 // Hauteur de la grille
    double k;                   // Conductivité thermique
    double q;                   // Source de chaleur de base
    double dt;                  // Pas de temps
    double dx;                  // Pas spatial
    HeatSource *sources;        // Tableau des sources thermiques
    int num_sources;            // Nombre de sources
} Grid;

// Prototypes de fonctions
Grid* create_grid(int width, int height, double k, double q, double dt, double dx);
void free_grid(Grid *grid);
void initialize_grid(Grid *grid);
GridPoint* get_point(Grid *grid, int x, int y);
void update_temperatures(Grid *grid);
void simulate_step(Grid *grid);
void export_temperatures(Grid *grid, const char *filename);
void print_grid(Grid *grid);
void add_heat_source(Grid *grid, int x, int y, double power, int radius);
void toggle_heat_source(Grid *grid, int index);
void apply_heat_sources(Grid *grid);

#endif // TEMPERATURE_H