const cloudinary = require('cloudinary').v2;

// 1. Configure Cloudinary
cloudinary.config({
  cloud_name: 'dzwv7azwx',
  api_key: '[REDACTED_CLOUDINARY_KEY]',
  api_secret: '[REDACTED_CLOUDINARY_SECRET]'
});

async function runTest() {
  try {
    console.log("Starting Cloudinary test...");

    // 2. Upload an image
    const uploadResult = await cloudinary.uploader.upload("https://res.cloudinary.com/demo/image/upload/sample.jpg", {
      public_id: "sample_test_coffee"
    });
    console.log("--- Upload Success ---");
    console.log("Secure URL:", uploadResult.secure_url);
    console.log("Public ID:", uploadResult.public_id);

    // 3. Get image details
    console.log("\n--- Image Metadata ---");
    console.log("Width:", uploadResult.width);
    console.log("Height:", uploadResult.height);
    console.log("Format:", uploadResult.format);
    console.log("Size (bytes):", uploadResult.bytes);

    // 4. Transform the image
    // f_auto: Automatically chooses the best format for the browser (e.g., WebP)
    // q_auto: Automatically optimizes quality to reduce file size without losing visible detail
    const transformedUrl = cloudinary.url(uploadResult.public_id, {
      fetch_format: 'auto',
      quality: 'auto'
    });
    
    console.log("\n--- Transformation ---");
    console.log("Done! Click link below to see optimized version of the image. Check the size and the format.");
    console.log("Transformed URL:", transformedUrl);

  } catch (error) {
    console.error("Test failed:", error);
  }
}

runTest();
