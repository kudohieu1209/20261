/*
 * memory_fixed.c - Tutorial 6: bản đã sửa của memory_error.c
 *
 * Ba lỗi Valgrind (Memcheck) phát hiện trong bản gốc và cách sửa:
 *   [SỬA 1] Ghi ngoài mảng   : ptr1[5] = 42      -> chỉ ghi trong chỉ số 0..4
 *   [SỬA 2] Con trỏ chưa khởi tạo: int *ptr2; *ptr2 -> cấp phát, kiểm tra, gán giá trị trước khi đọc
 *   [SỬA 3] Rò rỉ bộ nhớ     : quên free(ptr1), free(ptr3) -> free mọi khối đã malloc
 *
 * Biên dịch: gcc -g -Wall -Wextra -o memory_fixed memory_fixed.c
 * Kiểm tra : valgrind --leak-check=full --track-origins=yes --show-leak-kinds=all ./memory_fixed
 */
#include <stdio.h>
#include <stdlib.h>

#define N1 5  /* số phần tử của ptr1 */
#define N3 10 /* số phần tử của ptr3 */

int main(void) {
  // Allocate memory for 5 integers
  int *ptr1 = malloc(N1 * sizeof(int));
  if (ptr1 == NULL) {
    printf("Memory allocation failed!\n");
    return 1;
  }

  // [SỬA 1] Mảng N1 = 5 phần tử chỉ có chỉ số 0..4, nên phần tử cuối là ptr1[N1 - 1].
  // Khởi tạo cả mảng để không phần tử nào bị đọc khi còn chứa giá trị rác.
  for (int i = 0; i < N1; i++)
    ptr1[i] = 0;
  ptr1[N1 - 1] = 42;
  printf("ptr1[%d] = %d\n", N1 - 1, ptr1[N1 - 1]);

  // [SỬA 2] Con trỏ phải trỏ tới vùng nhớ hợp lệ trước khi dereference (*ptr2).
  // Cấp phát 1 int, kiểm tra malloc thành công, rồi GÁN giá trị trước khi đọc.
  int *ptr2 = malloc(sizeof(int));
  if (ptr2 == NULL) {
    printf("Memory allocation failed!\n");
    free(ptr1); // đã cấp ptr1 thì thoát sớm cũng phải trả lại
    return 1;
  }
  *ptr2 = 0;
  printf("Initialized value: %d\n", *ptr2);

  // Allocate additional memory for another pointer
  int *ptr3 = malloc(N3 * sizeof(int));
  if (ptr3 == NULL) {
    printf("Memory allocation failed!\n");
    free(ptr1);
    free(ptr2);
    return 1;
  }

  // [SỬA 3] Mỗi malloc phải có đúng một free tương ứng khi không dùng nữa.
  // Gán NULL sau free để nếu lỡ dùng lại thì lỗi lộ ra ngay (không thành dangling pointer).
  free(ptr1);
  ptr1 = NULL;
  free(ptr2);
  ptr2 = NULL;
  free(ptr3);
  ptr3 = NULL;

  return 0;
}
