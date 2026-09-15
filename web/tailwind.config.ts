import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      screens: {
        // Mobile-first breakpoints per WEB-DEVELOPER-BRIEF.md
        sm: '320px',   // Phone (5-6")
        md: '600px',   // Tablet 7"
        lg: '800px',   // Tablet 10"
        xl: '1024px',  // Desktop
        '2xl': '1440px', // Large desktop
      },
      colors: {
        // Praxia clinical therapeutic color palette
        cream: '#FFF8F0',
        sage: '#9DB9A3',
        teal: '#4A9B8E',
        warmAmber: '#D4A574',
        // Therapeutic - warm, non-punitive language
        success: '#7CB342', // Green, but warm-toned
        warning: '#FFA726', // Amber (no red failure states per C2)
        info: '#29B6F6',    // Blue
      },
      fontSize: {
        // Responsive text sizing for tablet/phone readability
        xs: '0.75rem',
        sm: '0.875rem',
        base: '1rem',
        lg: '1.125rem',
        xl: '1.25rem',
        '2xl': '1.5rem',
        '3xl': '1.875rem',
        '4xl': '2.25rem',
      },
      spacing: {
        // Touch target sizing (48-64px for tablets per C18)
        'touch': '3rem',    // 48px
        'touch-lg': '4rem', // 64px
      },
      minHeight: {
        'touch': '3rem',    // 48px minimum touch target
        'touch-lg': '4rem', // 64px recommended
      },
      minWidth: {
        'touch': '3rem',
        'touch-lg': '4rem',
      },
    },
  },
  plugins: [],
}

export default config
