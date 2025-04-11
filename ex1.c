#include <stdio.h>
#include <stdlib.h>

#define MAX_CLIENTS 100000


int abs_val(int x) {
    return x < 0 ? -x : x;
}

void swap(int *a, int *b) {
    int tmp = *a;
    *a = *b;
    *b = tmp;
}


void sort_by_diff(int diff[], int order[], int n) {
    for (int i = 0; i < n - 1; i++) {
        for (int j = i + 1; j < n; j++) {
            if (abs_val(diff[order[i]]) < abs_val(diff[order[j]])) {
                swap(&order[i], &order[j]);
            }
        }
    }
}


int main() {
    FILE *file;
    char line[256];
    int contracts_A;
    int contracts_B;
    int profit_A[MAX_CLIENTS];
    int profit_B[MAX_CLIENTS];
    int diff[MAX_CLIENTS], you_will_get[MAX_CLIENTS]; //you_will_get[i] will keep track which contract we give to which client. chosen = 1 for A and chosen = 2 for B
    int order[MAX_CLIENTS];
    int total_profit;

    file = fopen("contract.txt", "r"); // άνοιγμα αρχείου για ανάγνωση

    if (file == NULL) {
        printf("The file doesnt exist\n");
        return 1;
    }

    if (fscanf(file, "%d %d", &contracts_A, &contracts_B) != 2) {
        printf("Errror.\n");
        fclose(file);
        return 1;
    }

    int total_clients = contracts_A + contracts_B;

    for (int i = 0; i < total_clients; i++) {
    if (fscanf(file, "%d %d", &profit_A[i], &profit_B[i]) != 2) {
        printf("Error reading client %d\n", i + 1);
        fclose(file);
        return 1;
    }
    diff[i] = profit_A[i] - profit_B[i];
    you_will_get[i] = 0;
    order[i] = i;
}

    fclose(file);
    printf("Contracts A: %d, Contracts B: %d\n", contracts_A, contracts_B);
    for (int i = 0; i < total_clients; i++) {
        printf("Client %d: A = %d, B = %d, Difference = %d\n", i + 1, profit_A[i], profit_B[i], diff[i]);
    }
    sort_by_diff(diff, order, total_clients);

    for ( int i =0 ; i<total_clients; i++ ) {
        int a = order[i]; //the first one in the ordered list--> the one with the biggest difference. I will give him the contract with the biggest profit
        if ((profit_A[a] > profit_B[a] && contracts_A > 0) || contracts_B == 0) {  //if the best is the A and we have contracts_A available
           you_will_get[a] = 1; //we give the A
           contracts_A -- ;//one less contract_A
           total_profit += profit_A[a];  //calculate the profit
        }else if (contracts_B > 0) {
            you_will_get[a] = 2;  //we give the B
            contracts_B--;  //one less B
            total_profit += profit_B[a];
        }

    }


printf("Poios pire ti:\n");
    for (int i = 0; i < total_clients; i++) {
        if (you_will_get[i] == 1)
            printf("Client %d -> contract A (profit: %d)\n", i + 1, profit_A[i]);
        else if (you_will_get[i] == 2)
            printf("Client %d -> contract B (profit: %d)\n", i + 1, profit_B[i]);
        else
            printf("Client %d -> No contract\n", i + 1);
    }
    printf("\nTotal Profit: %d\n", total_profit);
    return 0;
}