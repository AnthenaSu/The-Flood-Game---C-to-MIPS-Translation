#include <stdio.h>
#include <stdlib.h>

///////////////
// CONSTANTS //
///////////////

#define TRUE 1
#define FALSE 0

#define UP_KEY 'w'
#define LEFT_KEY 'a'
#define DOWN_KEY 's'
#define RIGHT_KEY 'd'

#define FILL_KEY 'e'

#define CHEAT_KEY 'c'
#define HELP_KEY 'h'
#define EXIT_KEY 'q'

#define COLOUR_ONE '='
#define COLOUR_TWO 'x'
#define COLOUR_THREE '#'
#define COLOUR_FOUR '.'
#define COLOUR_FIVE '*'
#define COLOUR_SIX '`'
#define COLOUR_SEVEN '@'
#define COLOUR_EIGHT '&'

#define NUM_COLOURS 8

// Don't look at me!! :-:
#define MAX(a, b) ((a > b) ? (a) : (b))
#define MIN(a, b) ((a > b) ? (b) : (a))
// Nothing to see here

#define MIN_BOARD_WIDTH 3
#define MAX_BOARD_WIDTH 12
#define MIN_BOARD_HEIGHT 3
#define MAX_BOARD_HEIGHT 12

#define BOARD_VERTICAL_SEPERATOR '|'
#define BOARD_CROSS_SEPERATOR '+'
#define BOARD_HORIZONTAL_SEPERATOR '-'
#define BOARD_CELL_SEPERATOR '|'
#define BOARD_SPACE_SEPERATOR ' '
#define BOARD_CELL_SIZE 3

#define SELECTED_ARROW_VERTICAL_LENGTH 2

#define GAME_STATE_PLAYING 0
#define GAME_STATE_LOST 1
#define GAME_STATE_WON 2

#define NUM_VISIT_DELTAS 4
#define VISIT_DELTA_ROW 0
#define VISIT_DELTA_COL 1

#define MAX_SOLUTION_STEPS 64


#define NOT_VISITED 0
#define VISITED 1
#define ADJACENT 2

#define SIZEOF_INT sizeof(int)

#define EXTRA_STEPS 2

struct fill_in_progress {
    int cells_filled;
    char visited[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH];
    char fill_with;
    char fill_onto;
};

struct step_rating {
    int surface_area;
    int is_eliminated;
};

struct solver {
    struct step_rating step_rating_for_colour[NUM_COLOURS];
    int solution_length;
    char simulated_board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH];
    char future_board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH];
    char adjacent_to_cell[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH];
    char optimal_solution[MAX_SOLUTION_STEPS];
};

char selected_arrow_horizontal[] = "<--";
char selected_arrow_vertical[] = {'^', '|'};
char cmd_waiting[] = "> ";

char colour_selector[NUM_COLOURS] = {
    COLOUR_ONE, COLOUR_TWO, COLOUR_THREE, COLOUR_FOUR, 
    COLOUR_FIVE, COLOUR_SIX, COLOUR_SEVEN, COLOUR_EIGHT
};

char game_board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH];

int visit_deltas[4][2] = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}};



struct fill_in_progress global_fill_in_progress;

struct solver global_solver;

int selected_row;
int selected_column;
int board_width;
int board_height;


char optimal_solution[MAX_SOLUTION_STEPS];
int optimal_steps;
int extra_steps;

int steps;

int game_state;

unsigned int random_seed;

int invalid_step(struct solver *solver, int colour_index);
void initialise_solver_adjacent_cells(struct solver *solver);
void simulate_step(struct solver *solver, int colour_index);
void rate_choice(struct solver *solver, int colour_index);
void find_adjacent_cells(struct solver *solver, int row, int col);
void solve_next_step(struct solver *solver);
int game_finished(char board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH]);
unsigned int random_in_range(unsigned int min, unsigned int max);
void do_fill();
void fill(struct fill_in_progress *fill_in_progress, char board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH], 
    int row, int col);
void initialise_game();
void initialise_board();
void initialise_solver(struct solver *solver);
void print_board(char board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH]);
void print_board_bottom();
void print_board_row(char board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH], int row);
void print_board_inner_line(char board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH], 
        int row, int row_is_selected);
void print_board_seperator_line();
int in_bounds(int value, int minimum, int maximum);
void game_loop();
void process_command();
void print_welcome();
void initialise_fill_in_progress(struct fill_in_progress *init_me, char fill_with, char fill_onto);
void copy_mem(void *src, void *dst, int num_bytes);
void find_optimal_solution();
void print_optimal_solution();

//////////////
// SUBSET 0 //
//////////////

int main(void) {
    print_welcome();

    initialise_game();

    game_loop();

    return 0;
}

void print_welcome() {
    printf("Welcome to flood!\n");
    printf("To move your cursor up/down, use %c/%c\n", UP_KEY, DOWN_KEY);
    printf("To move your cursor left/right, use %c/%c\n", LEFT_KEY, RIGHT_KEY);
    printf("To see this message again, use %c\n", HELP_KEY);
    printf("To perform flood fill on the grid, use %c\n", FILL_KEY);
    printf("To cheat and see the 'optimal' solution, use %c\n", CHEAT_KEY);
    printf("To exit, use %c\n", EXIT_KEY);
}

//////////////
// SUBSET 1 //
//////////////

int in_bounds(int value, int minimum, int maximum) {
    if (value < minimum) {
        return 0;
    }

    if (value > maximum) {
        return 0;
    }

    return 1;
}

void game_loop() {
    print_board(game_board);
    while (game_state == GAME_STATE_PLAYING) {
        process_command();
    }

    if (game_state == GAME_STATE_WON) {
        printf("You win!\n");
    }

    if (game_state == GAME_STATE_LOST) {
        printf("You lose :(\n");
    }

    return;
}

void initialise_game() {
    int user_width;
    int user_height;
    int user_random_seed;

    while (1) {
        printf("Enter the grid width: ");
        scanf(" %d", &user_width);

        board_width = user_width; 

        if (!in_bounds(user_width, MIN_BOARD_WIDTH, MAX_BOARD_WIDTH)) {
            printf("Invalid width!\n");
            continue;
        }

        printf("Enter the grid height: ");
        scanf(" %d", &user_height);

        board_height = user_height;

        if (!in_bounds(user_height, MIN_BOARD_HEIGHT, MAX_BOARD_HEIGHT)) {
            printf("Invalid height!\n");
            continue;
        }

        break;
    }


    printf("Enter a random seed: ");
    scanf(" %d", &user_random_seed);
    random_seed = user_random_seed;

    selected_row = 0;
    selected_column = 0;
    steps = 0;
    extra_steps = EXTRA_STEPS;
    game_state = GAME_STATE_PLAYING;

    initialise_board();
    find_optimal_solution();

    return;
}

int game_finished(char board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH]) {
    char expected_colour = board[0][0];

    for (int row = 0; row < board_height; row++) {
        for (int col = 0; col < board_width; col++) {
            if (board[row][col] != expected_colour) {
                return FALSE;
            }
        }
    }

    return TRUE;
}

void do_fill() {
    initialise_fill_in_progress(&global_fill_in_progress,
        game_board[selected_row][selected_column], game_board[0][0]);
    
    fill(&global_fill_in_progress, game_board, 0, 0);

    printf("Filled %d cells!\n", global_fill_in_progress.cells_filled);
    
    steps++;

    if (game_finished(game_board)) {
        game_state = GAME_STATE_WON;
    }

    if (steps > optimal_steps + extra_steps) {
        game_state = GAME_STATE_LOST;
    }

    return;
}

//////////////
// SUBSET 2 //
//////////////

void initialise_fill_in_progress(struct fill_in_progress *init_me, char fill_with, char fill_onto) {
    init_me->fill_with = fill_with;
    init_me->fill_onto = fill_onto;
    init_me->cells_filled = 0;
    for (int row = 0; row < board_height; row++) {
        for (int col = 0; col < board_width; col++) {
            init_me->visited[row][col] = NOT_VISITED;
        }
    }

    return;
}

void initialise_board() {
    for (int row = 0; row < MAX_BOARD_HEIGHT; row++) {
        for (int col = 0; col < MAX_BOARD_WIDTH; col++) {
            int colour_selector_index = random_in_range(0, NUM_COLOURS - 1);
            game_board[row][col] = colour_selector[colour_selector_index];
        }
    }

    return;
}

void find_optimal_solution() {
    initialise_solver(&global_solver);

    while (!game_finished(global_solver.simulated_board)) {
        solve_next_step(&global_solver);
    }

    copy_mem(global_solver.optimal_solution, optimal_solution, global_solver.solution_length);
    optimal_solution[global_solver.solution_length] = '\0';

    optimal_steps = global_solver.solution_length;

    return;
}

int invalid_step(struct solver *solver, int colour_index) {
    // Step is invalid if it is the same colour as top left cell
    if (solver->simulated_board[0][0] == colour_selector[colour_index]) {
        return TRUE;
    }

    // Step is invalid if it does not increase the size of the flood
    initialise_solver_adjacent_cells(solver);
    find_adjacent_cells(solver, 0, 0);

    int found = FALSE;
    for (int row = 0; row < board_height; row++) {
        for (int col = 0; col < board_width; col++) {
           if (solver->simulated_board[row][col] == colour_selector[colour_index]
                    && solver->adjacent_to_cell[row][col] == ADJACENT) {
                found = TRUE;
            }
        }
    }

    if (found == TRUE) {
        return FALSE;
    } else {
        return TRUE;
    }
}

void print_optimal_solution() {
    char *s = optimal_solution;

    while (*s) {
        putchar(*s);
        s++;
        if (*s) {
            putchar(',');
            putchar(' ');
        } else {
            putchar('\n');
        }
    }

    s = optimal_solution;
    int i = 0;

    if (steps > optimal_steps) {
        putchar(10);
        return;
    }

    while (*s) {
        if (i == steps) {
            putchar('^');
        } else {
            putchar(' ');
        }
        putchar(' ');
        putchar(' ');
        s++;
        i++;
        if (!*s) {
            putchar('\n');
        }
    }

    return;
}

//////////////
// SUBSET 3 //
//////////////

void rate_choice(struct solver *solver, int colour_index) {
    // If ALL instances of this colour lie in adjacent cells, then choosing it would eliminate
    // that colour
    solver->step_rating_for_colour[colour_index].is_eliminated = TRUE;
    
    // We can then just count the number of adjacent cells in the loop
    solver->step_rating_for_colour[colour_index].surface_area = 0;
    
    int seen = FALSE;

    for (int row = 0; row < board_height; row++) {
        for (int col = 0; col < board_width; col++) {
            if (solver->simulated_board[row][col] == colour_selector[colour_index]) {
                seen = TRUE;
            }
            if (solver->adjacent_to_cell[row][col] == NOT_VISITED) {
                solver->step_rating_for_colour[colour_index].is_eliminated = FALSE;
            } else if (solver->adjacent_to_cell[row][col] == ADJACENT) {
                solver->step_rating_for_colour[colour_index].surface_area++;
            }
        }
    }

    // Pointless to fill on nonexistent colour
    if (!seen) {
        solver->step_rating_for_colour[colour_index].is_eliminated = FALSE;
    }

    return;
}

void find_adjacent_cells(struct solver *solver, int row, int col) {
    char fill_region_colour = solver->simulated_board[0][0];
    
    if (solver->adjacent_to_cell[row][col] != NOT_VISITED) {
        return;
    }

    if (solver->simulated_board[row][col] != fill_region_colour) {
        solver->adjacent_to_cell[row][col] = ADJACENT;
        return;
    } else {
        solver->adjacent_to_cell[row][col] = VISITED;
    }


    for (int i = 0; i < NUM_VISIT_DELTAS; i++) {
        int row_delta = visit_deltas[i][VISIT_DELTA_ROW];
        int col_delta = visit_deltas[i][VISIT_DELTA_COL];

        if (!in_bounds(row + row_delta, 0, board_height - 1)) {
            continue;
        }

        if (!in_bounds(col + col_delta, 0, board_width - 1)) {
            continue;
        }

        find_adjacent_cells(solver, row + row_delta, col + col_delta);
    }

    return;
}

void fill(struct fill_in_progress *fill_in_progress, char board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH], 
        int row, int col) {
    if (fill_in_progress->visited[row][col] == VISITED) {
        return;
    }

    fill_in_progress->visited[row][col] = VISITED;

    if (board[row][col] != fill_in_progress->fill_onto) {
        return;
    }

    if (board[row][col] != fill_in_progress->fill_with) {
        fill_in_progress->cells_filled++;
    }

    board[row][col] = fill_in_progress->fill_with;

    for (int i = 0; i < NUM_VISIT_DELTAS; i++) {
        int row_delta = visit_deltas[i][VISIT_DELTA_ROW];
        int col_delta = visit_deltas[i][VISIT_DELTA_COL];

        if (!in_bounds(row + row_delta, 0, board_height - 1)) {
            continue;
        }

        if (!in_bounds(col + col_delta, 0, board_width - 1)) {
            continue;
        }

        fill(fill_in_progress, board, row + row_delta, col + col_delta);
    }

    return;
}

// Suboptimal greedy solution to decide what is optimal to fill next.
// Source: https://puzzling.stackexchange.com/a/46737.
// Greedy first for eliminating a colour,
// and second for maximum surface area (surface area = number of unique touching cells).
void solve_next_step(struct solver *solver) {
    int best_surface_area;
    int best_solution;
    copy_mem(solver->simulated_board, solver->future_board, MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT);
    // For each colour, simulate one fill and count the new "surface area"
    for (int i = 0; i < NUM_COLOURS; i++) {
        copy_mem(solver->future_board, solver->simulated_board, MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT);

        if (invalid_step(solver, i)) {
            solver->step_rating_for_colour[i].is_eliminated = FALSE;
            solver->step_rating_for_colour[i].surface_area = -1;
            continue;
        }

        simulate_step(solver, i);

        initialise_solver_adjacent_cells(solver);
        find_adjacent_cells(solver, 0, 0);
        rate_choice(solver, i);
    }

    copy_mem(solver->future_board, solver->simulated_board, MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT);
    
    // Choose the best step: apply this to the board and record which step it was

    // Try see if any eliminate a colour?
    for (int i = 0; i < NUM_COLOURS; i++) {
        if (solver->step_rating_for_colour[i].is_eliminated) {
            solver->optimal_solution[solver->solution_length] = colour_selector[i];
            solver->solution_length++;
            simulate_step(solver, i);
            copy_mem(solver->simulated_board, solver->future_board, 
                    MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT);
            return;
        }
    }

    // If no steps could eliminate a colour, choose the largest surface area
    best_surface_area = -1;
    best_solution = -1;

    for (int i = 0; i < NUM_COLOURS; i++) {
        if (solver->step_rating_for_colour[i].surface_area > best_surface_area) {
            best_solution = i;
            best_surface_area = solver->step_rating_for_colour[i].surface_area;
        }
    }

    solver->optimal_solution[solver->solution_length] = colour_selector[best_solution];
    solver->solution_length++;
    simulate_step(solver, best_solution);
    copy_mem(solver->simulated_board, solver->future_board, MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT);
    return;

}

// Assumes *src and *dst are 4-byte aligned
void copy_mem(void *src, void *dst, int num_bytes) {
    int *src_int_ptr = (int*) src;
    int *dst_int_ptr = (int*) dst;
    char *src_char_ptr;
    char *dst_char_ptr;

    for (int i = 0; i < num_bytes / SIZEOF_INT; i++) {
        *dst_int_ptr = *src_int_ptr;
        dst_int_ptr++;
        src_int_ptr++;
    }

    src_char_ptr = (char*) src_int_ptr;
    dst_char_ptr = (char*) dst_int_ptr;

    for (int i = 0; i < num_bytes % SIZEOF_INT; i++) {
        *dst_char_ptr = *src_char_ptr;
        dst_char_ptr++;
        src_char_ptr++;
    }

    return;
}

//////////////
// PROVIDED //
//////////////

unsigned int random_in_range(unsigned int min, unsigned int max) {
    int a = 16807;
    int m = 2147483647;
    random_seed = (a * random_seed) % m;
    return min + random_seed % (max - min + 1);
}

void initialise_solver(struct solver *solver) {
    solver->solution_length = 0;
    copy_mem(game_board, solver->simulated_board, MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT);
    return;
}


void simulate_step(struct solver *solver, int colour_index) {
    initialise_fill_in_progress(&global_fill_in_progress, 
            colour_selector[colour_index], solver->simulated_board[0][0]);
    fill(&global_fill_in_progress, solver->simulated_board, 0, 0);
    return;
}

void initialise_solver_adjacent_cells(struct solver *solver) {
    for (int row = 0; row < board_height; row++) {
        for (int col = 0; col < board_width; col++) {
            solver->adjacent_to_cell[row][col] = NOT_VISITED;
        }
    }
    return;
}

void print_board(char board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH]) {
    for (int row = 0; row < board_height; row++) {
        print_board_row(board, row);
    }
    print_board_seperator_line();
    print_board_bottom();

    printf("%d/%d steps\n", steps, optimal_steps + EXTRA_STEPS);
    return;
}

void print_board_bottom() {
    for (int i = 0; i < SELECTED_ARROW_VERTICAL_LENGTH + 1; i++) {
        putchar(BOARD_SPACE_SEPERATOR);
        for (int j = 0; j < board_width; j++) {
            if (j == selected_column) {
                for (int k = 0; k < ((BOARD_CELL_SIZE + 1) / 2); k++) {
                    putchar(BOARD_SPACE_SEPERATOR);
                }
                if (i == 0) {
                    putchar(BOARD_SPACE_SEPERATOR);
                } else {
                    putchar(selected_arrow_vertical[i - 1]);
                }
                for (int k = 0; k < ((BOARD_CELL_SIZE + 1) / 2); k++) {
                    putchar(BOARD_SPACE_SEPERATOR);
                }
            } else {
                for (int k = 0; k < BOARD_CELL_SIZE + 3; k++) {
                    putchar(BOARD_SPACE_SEPERATOR);
                }
            }
        }
        putchar(BOARD_SPACE_SEPERATOR);
        putchar('\n');
    }
    return;
}

void print_board_row(char board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH], int row) {
    print_board_seperator_line();
    for (int i = 0; i < BOARD_CELL_SIZE; i++) {
        print_board_inner_line(board, row, i == BOARD_CELL_SIZE / 2 && row == selected_row);
    }
    return;
}

void print_board_inner_line(char board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH], 
        int row, int row_is_selected) {
    putchar(BOARD_VERTICAL_SEPERATOR);
    for (int i = 0; i < board_width; i++) {
        putchar(BOARD_SPACE_SEPERATOR);
        for (int j = 0; j < BOARD_CELL_SIZE; j++) {
            putchar(board[row][i]);
        }
        putchar(BOARD_SPACE_SEPERATOR);
        if (i != board_width - 1) {
            putchar(BOARD_CELL_SEPERATOR);
        }
    }
    putchar(BOARD_VERTICAL_SEPERATOR);
    if (row_is_selected) {
        putchar(BOARD_SPACE_SEPERATOR);
        printf("%s", selected_arrow_horizontal);
    }
    putchar('\n');
    return;
}

void print_board_seperator_line() {
    putchar(BOARD_VERTICAL_SEPERATOR);
    for (int i = 0; i < board_width; i++) {
        for (int j = 0; j < BOARD_CELL_SIZE + 2; j++) {
            putchar(BOARD_HORIZONTAL_SEPERATOR);
        }
        if (i != board_width - 1) {
            putchar(BOARD_CROSS_SEPERATOR);
        }
    }
    putchar(BOARD_VERTICAL_SEPERATOR);
    putchar('\n');
    return;
}

void process_command() {
    printf("%s", cmd_waiting);
    char command = getchar();
    // How to write good parsing in C? idk..
    while (command == '\n') {
        command = getchar();
    }

    switch (command) {
        case UP_KEY: selected_row = MAX(selected_row - 1, 0); break;
        case DOWN_KEY: selected_row = MIN(selected_row + 1, board_height - 1); break;
        case RIGHT_KEY: selected_column = MIN(selected_column + 1, board_width - 1); break;
        case LEFT_KEY: selected_column = MAX(selected_column - 1, 0); break;
        case EXIT_KEY: exit(0);
        case FILL_KEY: do_fill(); break;
        case HELP_KEY: print_welcome(); return;
        case CHEAT_KEY: print_optimal_solution(); return;
        default: printf("Unknown command: %c\n", command); return;
    }
    print_board(game_board);
    return;
}