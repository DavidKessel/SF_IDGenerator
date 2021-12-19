## SF ID-Generator
## Generates a custom ID for your Contact records

### The requirement
One of my clients asked me to implement a solution that automatically assigns a custom non-SF ID to all Contacts upon creation or update of the record.

The custom ID should be alphanumeric and look like the following: `AB1231`

#### Generating the ID
1. randomly generate 2 letters
2. randomly generate 3 digits
3. calculate and append a verification number

#### Building the verification number
1. replace letters with their alphabetical index
2. all digits with modulo 10
3. multiply all digits alternately by 1 and 2
4. calculate the check sum from each product
5. add check sums together
6. sum modulo 10

##### Example:
If we randomly generated `KW940`, then the verification number must be `4`
1. K = 11, W = 23 ==> Therefore, the sequence is `11 23 9 4 0`
2. with modulo    ==> `1 3 9 4 0`
3. multiplied by 1s or 2s ==> `1 6 9 8 0`
4. with check sum ==> `1 6 9 8 0`
5. all added together ==> `24`
6. modulo of 24 ==> `4` 
The ID therefore is `KW9404`.

