# XXImagePicker
edit any height and width for image picked from the photo gallery


Step 1: Copy XXImagePicker directory in the project

Step 2: Use the XXImagePicker

add codes below when needed:

//  ratio = height / width
XXImagePickerController *controller = [[XXImagePickerController alloc] initWithRatio:ratio];
controller.delegateXX = self;
[self presentViewController:controller animated:YES completion:nil];

