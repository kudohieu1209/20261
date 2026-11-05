#include <stdio.h>
#include <stdlib.h>

int main() {
  // Allocate memory for 5 integers
  int *ptr1 = malloc(5 * sizeof(int));
  if (ptr1 == NULL) {
     printf("Memory allocation failed!\n");
     return 1;
  }

 // Invalid memory access: out-of-bounds write
 ptr1[5] = 42; // Accessing ptr1[5] is invalid (valid indices are 0 to 4)

 // Use of uninitialized memory
 int value = 7;      // [Bước 1] chỉ sửa lỗi ptr2 để chương trình không crash
 int *ptr2 = &value; // ptr2 trỏ vào biến hợp lệ
 printf("Uninitialized value: %d\n", *ptr2); // Dereferencing an uninitialized pointer

 // Memory leak: ptr1 is allocated but never freed
 // No call to free(ptr1)

 // Allocate additional memory for another pointer but forget to free it
 int *ptr3 = malloc(10 * sizeof(int));
 // No call to free(ptr3)
    return 0;
}
