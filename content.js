// Function to hide Discord GIFs
function hideDiscordGifs() {
  console.log("hideDiscordGifs called"); // Log when the function is called

  // Target both img and video elements within the imageContent container
  const gifElements = document.querySelectorAll('div[class*="imageContent"] img[src*=".gif"], div[class*="imageContent"] video[src*=".mp4"]');

  gifElements.forEach((element) => {
    // Find the closest ancestor that matches the general pattern of 'imageContent'
    const gifContainer = element.closest('div[class*="imageContent"]');
    if (gifContainer) {
      console.log("Hiding a GIF element", element); // Log when a GIF is being hidden
      hideElement(gifContainer);
    }
  });
}

// Function to hide the specified element
function hideElement(element) {
  console.log("hideElement called for", element); // Log the element being hidden
  element.style.display = 'none';
}

// MutationObserver callback
const observerCallback = (mutationsList, observer) => {
  for (const mutation of mutationsList) {
    console.log("Mutation observed", mutation); // Log the mutation observed
    if (mutation.type === 'childList' || mutation.type === 'subtree') {
      hideDiscordGifs();
    }
  }
};

// Create a more aggressive observer configuration
const observerOptions = {
  childList: true,
  subtree: true,
  attributes: false,
  characterData: false
};

// Instantiate and start the MutationObserver
const observer = new MutationObserver(observerCallback);
observer.observe(document.body, observerOptions);