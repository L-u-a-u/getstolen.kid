<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            overflow: hidden;
            cursor: none;
        }
        
        body {
            font-family: 'Courier New', monospace;
            background-color: #000;
            color: #0f0;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
            text-shadow: 0 0 5px #0f0;
        }
        
        .container {
            text-align: center;
            padding: 2rem;
            max-width: 800px;
            position: relative;
            z-index: 2;
        }
        
        h1 {
            font-size: 3rem;
            margin-bottom: 2rem;
            opacity: 0;
            animation: typeIn 2s steps(50) forwards;
        }
        
        .message {
            font-size: 1.5rem;
            margin-bottom: 2rem;
            opacity: 0;
            animation: typeIn 1.5s steps(100) 2s forwards;
        }
        
        .error-code {
            font-size: 1.25rem;
            opacity: 0;
            animation: blink 1s infinite 4s;
        }
        
        .access-denied {
            color: #f00;
            text-shadow: 0 0 10px #f00;
            font-weight: bold;
            font-size: 2.5rem;
            position: absolute;
            top: 20%;
            left: 50%;
            transform: translateX(-50%);
            opacity: 0;
            animation: fadeIn 0.5s forwards 5s;
        }
        
        .overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: repeating-linear-gradient(
                45deg,
                rgba(0, 0, 0, 0.1),
                rgba(0, 0, 0, 0.1) 2px,
                rgba(0, 0, 0, 0.2) 2px,
                rgba(0, 0, 0, 0.2) 4px
            );
            pointer-events: none;
            z-index: 10;
        }
        
        .scanline {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background-color: rgba(0, 255, 0, 0.3);
            z-index: 11;
            animation: scanline 4s linear infinite;
            pointer-events: none;
        }
        
        .custom-cursor {
            position: fixed;
            width: 20px;
            height: 20px;
            border: 2px solid #0f0;
            border-radius: 50%;
            transform: translate(-50%, -50%);
            pointer-events: none;
            z-index: 9999;
            animation: pulse 1s infinite alternate;
        }
        
        .glitch {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: transparent;
            z-index: 12;
            pointer-events: none;
            animation: glitch 10s infinite;
            opacity: 0;
        }
        
        .loading-bar {
            width: 0%;
            height: 20px;
            background: linear-gradient(90deg, #0f0, #00ff00);
            margin: 2rem auto;
            position: relative;
            border: 1px solid #0f0;
            opacity: 0;
            animation: loadBar 3s forwards 6s;
        }
        
        .loading-bar:after {
            content: "SEARCHING...";
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #000;
            font-weight: bold;
        }
        
        @keyframes typeIn {
            from { opacity: 0; width: 0; }
            to { opacity: 1; width: 100%; }
        }
        
        @keyframes blink {
            0%, 100% { opacity: 1; }
            50% { opacity: 0; }
        }
        
        @keyframes scanline {
            0% { top: 0%; }
            100% { top: 100%; }
        }
        
        @keyframes pulse {
            from { transform: translate(-50%, -50%) scale(0.8); }
            to { transform: translate(-50%, -50%) scale(1.2); }
        }
        
        @keyframes glitch {
            0%, 95%, 100% { opacity: 0; }
            95.5%, 96% { opacity: 0.5; }
            96.5%, 97% { opacity: 0; }
            97.5%, 98% { opacity: 0.7; }
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        @keyframes loadBar {
            0% { opacity: 1; width: 0%; }
            80% { width: 95%; }
            100% { width: 100%; }
        }
        
        .warning {
            position: fixed;
            bottom: 20px;
            left: 0;
            width: 100%;
            text-align: center;
            font-size: 1rem;
            color: #f00;
            opacity: 0;
            animation: fadeIn 1s forwards 9s;
        }
        
        .escape-message {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 3rem;
            color: #f00;
            text-shadow: 0 0 15px #f00;
            z-index: 100;
            opacity: 0;
            display: none;
        }
    </style>
</head>
<body>
    <div class="overlay"></div>
    <div class="scanline"></div>
    <div class="glitch"></div>
    <div class="custom-cursor"></div>
    
    <div class="container">
        <h1>What are you Searching for?</h1>
        <p class="message">SYSTEM: Unauthorized access detected. IP logged.</p>
        <div class="loading-bar"></div>
        <p class="error-code">ERROR CODE: 403-FORBIDDEN > _</p>
    </div>
    
    <div class="access-denied">ACCESS DENIED</div>
    
    <div class="warning">WARNING: All activity is being monitored and reported</div>
    
    <div class="escape-message">YOU CAN'T ESCAPE</div>

    <script>
        // Custom cursor
        const cursor = document.querySelector('.custom-cursor');
        document.addEventListener('mousemove', (e) => {
            cursor.style.left = `${e.clientX}px`;
            cursor.style.top = `${e.clientY}px`;
        });
        
        // Random glitch effects
        setInterval(() => {
            if (Math.random() > 0.95) {
                document.body.style.filter = `hue-rotate(${Math.random() * 360}deg)`;
                setTimeout(() => {
                    document.body.style.filter = '';
                }, 100);
            }
        }, 500);
        
        // Prevent scrolling and show "can't escape" message
        let escapeAttempts = 0;
        const escapeMessage = document.querySelector('.escape-message');
        
        document.addEventListener('mouseleave', () => {
            showEscapeMessage();
        });
        
        document.addEventListener('contextmenu', (e) => {
            e.preventDefault();
            showEscapeMessage();
        });
        
        document.addEventListener('keydown', (e) => {
            if (e.key === 'F12' || (e.ctrlKey && e.shiftKey && (e.key === 'I' || e.key === 'J' || e.key === 'C')) || 
                (e.ctrlKey && e.key === 'u')) {
                e.preventDefault();
                showEscapeMessage();
            }
            
            // Block ctrl+a (select all)
            if (e.ctrlKey && e.key === 'a') {
                e.preventDefault();
            }
        });
        
        // Prevent drag operation
        document.addEventListener('dragstart', (e) => {
            e.preventDefault();
        });
        
        // Prevent text selection
        document.addEventListener('selectstart', (e) => {
            e.preventDefault();
        });
        
        // Prevent default touch behavior to disable scroll
        document.addEventListener('touchmove', (e) => {
            e.preventDefault();
        }, { passive: false });
        
        // Prevent scroll
        document.addEventListener('wheel', (e) => {
            e.preventDefault();
            showEscapeMessage();
        }, { passive: false });
        
        function showEscapeMessage() {
            escapeAttempts++;
            
            if (escapeAttempts >= 3) {
                escapeMessage.style.display = 'block';
                escapeMessage.style.animation = 'fadeIn 0.5s forwards';
                
                setTimeout(() => {
                    escapeMessage.style.animation = 'fadeIn 0.5s reverse forwards';
                    setTimeout(() => {
                        escapeMessage.style.display = 'none';
                    }, 500);
                }, 2000);
            }
        }
        
        // Add some random typing sounds
        function playRandomSound() {
            if (Math.random() > 0.7) {
                const audio = new Audio();
                audio.volume = 0.1;
                audio.src = 'data:audio/mp3;base64,SUQzBAAAAAAAI1RTU0UAAAAPAAADTGF2ZjU4Ljc2LjEwMAAAAAAAAAAAAAAA/+M4wAAAAAAAAAAAAEluZm8AAAAPAAAAAwAAAbAAqKioqKioqKioqKioqKioqKio19fX19fX19fX19fX19fX19fX1/n5+fn5+fn5+fn5+fn5+fn5+fkAAABMYXZjNTguMTM0AAAAAAAAAAAAACQCQAAAAAAAAGCxzGwSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP/jOMAAAAP8AAANIAAAAAExBTUUzLjEwMFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVUxCTUUzLjEwMFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVUxCTUUzLjEwMFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV';
                audio.play();
            }
        }
        
        setInterval(playRandomSound, 200);
        
        // Add fake countdown after loading
        setTimeout(() => {
            const container = document.querySelector('.container');
            const countdown = document.createElement('div');
            countdown.style.marginTop = '2rem';
            countdown.style.fontSize = '1.5rem';
            countdown.style.animation = 'blink 1s infinite';
            countdown.textContent = 'LOCATION TRACED, AUTHORITIES DISPATCHED: ETA 00:30';
            container.appendChild(countdown);
            
            let seconds = 30;
            const interval = setInterval(() => {
                seconds--;
                if (seconds <= 0) {
                    clearInterval(interval);
                    countdown.textContent = 'CONNECTION TERMINATED';
                    countdown.style.color = '#f00';
                    
                    // Final scare
                    setTimeout(() => {
                        document.body.style.backgroundColor = '#f00';
                        document.body.innerHTML = '<div style="display:flex;justify-content:center;align-items:center;height:100vh;font-size:5rem;color:white;text-shadow:0 0 20px black;">SYSTEM BREACH DETECTED</div>';
                        
                        setTimeout(() => {
                            document.body.style.backgroundColor = '#000';
                            document.body.innerHTML = '<div style="display:flex;justify-content:center;align-items:center;height:100vh;font-size:2rem;color:#0f0;text-shadow:0 0 10px #0f0;">Haha, gotcha! Just a troll website.</div>';
                        }, 2000);
                    }, 3000);
                } else {
                    const formattedSeconds = seconds < 10 ? `0${seconds}` : seconds;
                    countdown.textContent = `LOCATION TRACED, AUTHORITIES DISPATCHED: ETA 00:${formattedSeconds}`;
                }
            }, 1000);
        }, 10000);
        
        // Create artificial lag
        window.addEventListener('mousemove', () => {
            if (Math.random() > 0.98) {
                cursor.style.transition = 'left 0.5s, top 0.5s';
                setTimeout(() => {
                    cursor.style.transition = 'none';
                }, 500);
            }
        });
    </script>
</body>
</html>
